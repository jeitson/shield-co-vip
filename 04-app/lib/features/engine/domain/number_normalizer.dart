/// Normaliza números a formato canónico **E.164** antes de hashear/comparar
/// (RN-04). Debe ser idéntico al servidor para que los HMAC coincidan.
///
/// Reglas (Colombia):
/// - Móvil CO = 10 dígitos que empiezan en `3` → `+57` + 10 dígitos.
/// - Si ya viene con `+57` o `57` delante, se normaliza igual.
/// - **Códigos cortos SMS** (p. ej. `890123`, 4–6 dígitos) se tratan aparte: no
///   se normalizan a E.164, se devuelven tal cual (categoría distinta, RN-04).
abstract final class NumberNormalizer {
  /// Devuelve el número en E.164 (`+57XXXXXXXXXX`) o, si es un código corto, el
  /// propio código sin cambios. Devuelve `null` si no se puede interpretar.
  static String? normalize(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;

    // Código corto SMS: 3–6 dígitos, no es un móvil.
    if (digits.length >= 3 && digits.length <= 6) {
      return digits;
    }

    // Quitar prefijo de país si viene incluido.
    var local = digits;
    if (local.startsWith('57') && local.length == 12) {
      local = local.substring(2);
    }

    // Móvil CO válido: 10 dígitos empezando en 3.
    if (local.length == 10 && local.startsWith('3')) {
      return '+57$local';
    }

    // No reconocido como móvil CO ni código corto.
    return null;
  }

  /// `true` si el valor normalizado es un código corto (no un E.164).
  static bool isShortCode(String normalized) => !normalized.startsWith('+');
}
