package com.cifradocero.shield_app.call

import android.telecom.Call
import android.telecom.CallScreeningService
import com.cifradocero.shield_app.engine.Decision
import com.cifradocero.shield_app.engine.EventQueueStore
import com.cifradocero.shield_app.engine.Hmac
import com.cifradocero.shield_app.engine.MatchResult
import com.cifradocero.shield_app.engine.NumberNormalizer
import com.cifradocero.shield_app.engine.PepperStore
import com.cifradocero.shield_app.engine.PrecedenceMatcher
import com.cifradocero.shield_app.engine.SnapshotStore

/**
 * Intercepta llamadas entrantes (`04-app-flutter` §04.5). Corre en su propio
 * proceso: decide de forma **nativa** con el snapshot proyectado por Dart, sin
 * depender del engine Flutter. Hashea el número con el pepper (keystore nativo)
 * y aplica la precedencia de 5 niveles.
 */
class CallScreeningServiceImpl : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        val raw = callDetails.handle?.schemeSpecificPart
        val result = evaluate(raw)

        val responseBuilder = CallResponse.Builder()
        if (result.decision == Decision.BLOCK) {
            // Rechazar sin timbrar, sin dejar rastro en el registro de llamadas.
            responseBuilder
                .setDisallowCall(true)
                .setRejectCall(true)
                .setSkipCallLog(false) // dejar constancia en el log del sistema
                .setSkipNotification(true)

            // Encolar el evento interceptado para que Dart lo persista al
            // reanudar (el servicio corre sin FlutterEngine vivo). Guarda el
            // número crudo: el historial es local (RN-01) y Dart lo normaliza.
            if (raw != null) {
                EventQueueStore(applicationContext).enqueue(
                    rawNumber = raw,
                    channel = "call",
                    layer = result.layer,
                    body = null,
                )
            }
        }
        respondToCall(callDetails, responseBuilder.build())
    }

    private fun evaluate(raw: String?): MatchResult {
        val allow = MatchResult(Decision.ALLOW, null)
        if (raw == null) return allow
        val e164 = NumberNormalizer.normalize(raw) ?: return allow

        val snapshot = SnapshotStore(applicationContext).read() ?: return allow
        val pepper = PepperStore(applicationContext).getPepper() ?: return allow

        val hash = Hmac.sha256Hex(pepper, e164)
        return PrecedenceMatcher.evaluate(hash, snapshot)
    }
}
