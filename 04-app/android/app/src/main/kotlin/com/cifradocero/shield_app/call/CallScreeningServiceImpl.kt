package com.cifradocero.shield_app.call

import android.telecom.Call
import android.telecom.CallScreeningService
import com.cifradocero.shield_app.engine.Decision
import com.cifradocero.shield_app.engine.Hmac
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
        val decision = evaluate(callDetails)

        val responseBuilder = CallResponse.Builder()
        if (decision == Decision.BLOCK) {
            // Rechazar sin timbrar, sin dejar rastro en el registro de llamadas.
            responseBuilder
                .setDisallowCall(true)
                .setRejectCall(true)
                .setSkipCallLog(false) // dejar constancia en el log del sistema
                .setSkipNotification(true)
        }
        respondToCall(callDetails, responseBuilder.build())
    }

    private fun evaluate(details: Call.Details): Decision {
        val raw = details.handle?.schemeSpecificPart ?: return Decision.ALLOW
        val e164 = NumberNormalizer.normalize(raw) ?: return Decision.ALLOW

        val snapshot = SnapshotStore(applicationContext).read() ?: return Decision.ALLOW
        val pepper = PepperStore(applicationContext).getPepper() ?: return Decision.ALLOW

        val hash = Hmac.sha256Hex(pepper, e164)
        return PrecedenceMatcher.decide(hash, snapshot)
    }
}
