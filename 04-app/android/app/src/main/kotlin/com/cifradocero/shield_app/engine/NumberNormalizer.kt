package com.cifradocero.shield_app.engine

/**
 * Normalización E.164 para Colombia, idéntica a `NumberNormalizer` de Dart
 * (RN-04). Debe coincidir con el servidor para que los HMAC cuadren.
 */
object NumberNormalizer {

    /** E.164 (`+57XXXXXXXXXX`), código corto tal cual, o `null` si no aplica. */
    fun normalize(raw: String): String? {
        val digits = raw.filter { it.isDigit() }
        if (digits.isEmpty()) return null

        // Código corto SMS (3–6 dígitos).
        if (digits.length in 3..6) return digits

        var local = digits
        if (local.startsWith("57") && local.length == 12) {
            local = local.substring(2)
        }

        // Móvil CO: 10 dígitos empezando en 3.
        if (local.length == 10 && local.startsWith("3")) {
            return "+57$local"
        }
        return null
    }
}
