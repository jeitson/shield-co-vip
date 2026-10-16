package com.cifradocero.shield_app.engine

import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

/**
 * HMAC-SHA256(pepper, numeroE164) en hex minúsculas.
 *
 * Debe producir EXACTAMENTE el mismo valor que el servidor (pgcrypto) y que el
 * `HmacHasher` de Dart, o el matching no coincide. Clave = bytes UTF-8 del
 * pepper; mensaje = bytes UTF-8 del número E.164. Verificado con vector real.
 */
object Hmac {
    fun sha256Hex(pepper: String, numberE164: String): String {
        val mac = Mac.getInstance("HmacSHA256")
        mac.init(SecretKeySpec(pepper.toByteArray(Charsets.UTF_8), "HmacSHA256"))
        val bytes = mac.doFinal(numberE164.toByteArray(Charsets.UTF_8))
        val sb = StringBuilder(bytes.size * 2)
        for (b in bytes) sb.append("%02x".format(b))
        return sb.toString()
    }
}
