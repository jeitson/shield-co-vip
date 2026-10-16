package com.cifradocero.shield_app.sms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import com.cifradocero.shield_app.engine.Decision
import com.cifradocero.shield_app.engine.EventQueueStore
import com.cifradocero.shield_app.engine.Hmac
import com.cifradocero.shield_app.engine.NumberNormalizer
import com.cifradocero.shield_app.engine.PepperStore
import com.cifradocero.shield_app.engine.PrecedenceMatcher
import com.cifradocero.shield_app.engine.SnapshotStore

/**
 * Inspección **no-destructiva** de SMS (decisión del usuario): la app NO es la
 * app de SMS por defecto; solo escucha `SMS_RECEIVED` con permiso RECEIVE_SMS
 * para evaluar el remitente y detectar links/dominios sospechosos. Detecta y
 * (a futuro) alerta; nunca borra ni bloquea el SMS. Ver spec 05 §R5.
 */
class SmsReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
        if (messages.isEmpty()) return

        val sender = messages.first().originatingAddress ?: return
        val body = messages.joinToString(separator = "") { it.messageBody ?: "" }

        val snapshot = SnapshotStore(context.applicationContext).read() ?: return
        val pepper = PepperStore(context.applicationContext).getPepper() ?: return

        // 1) Evaluar el remitente contra la precedencia.
        val e164 = NumberNormalizer.normalize(sender)
        if (e164 != null) {
            val hash = Hmac.sha256Hex(pepper, e164)
            val result = PrecedenceMatcher.evaluate(hash, snapshot)
            if (result.decision == Decision.BLOCK) {
                SmsThreatLog.record(context, sender, "remitente peligroso")
                // No se borra el SMS (no somos app por defecto): solo alerta.
                // Encolar para el historial de eventos (feature `events`): el
                // body se conserva como contenido en cuarentena (sandbox local).
                EventQueueStore(context.applicationContext).enqueue(
                    rawNumber = sender,
                    channel = "sms",
                    layer = result.layer,
                    body = body,
                )
            }
        }

        // 2) Extraer dominios de los links del cuerpo para verificación futura
        //    (domain_hashes). Hoy se registran; el matching de dominios se
        //    activa cuando el dataset incluya esa sección (03-datos §03.3).
        val domains = UrlExtractor.domains(body)
        if (domains.isNotEmpty()) {
            SmsThreatLog.record(context, sender, "links: ${domains.joinToString()}")
        }
    }
}

/** Extrae dominios de las URLs presentes en un texto. */
object UrlExtractor {
    private val urlRegex = Regex("""https?://([\w.-]+)""", RegexOption.IGNORE_CASE)

    fun domains(text: String): List<String> =
        urlRegex.findAll(text).map { it.groupValues[1].lowercase() }.distinct().toList()
}

/** Registro mínimo de amenazas SMS (placeholder para el historial de eventos). */
object SmsThreatLog {
    fun record(context: Context, sender: String, reason: String) {
        // El historial de eventos (feature `events`) persistirá esto más
        // adelante. Por ahora, punto de integración único y sin PII en logs.
        android.util.Log.i("SmsReceiver", "SMS marcado ($reason)")
    }
}
