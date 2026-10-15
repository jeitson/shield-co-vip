/// Value object de celular móvil colombiano.
///
/// Reglas (RN-REG-04 / RN-04): exactamente 10 dígitos que inician en `3`.
/// El prefijo de país `+57` es responsabilidad de este VO (no de la UI,
/// RF-REG-02) y se canoniza a E.164 `+57XXXXXXXXXX` para deduplicar y comparar.
class ColombianPhone {
  const ColombianPhone._(this.e164, this.nationalNumber);

  /// Número canónico E.164, ej. `+573001234567`.
  final String e164;

  /// Los 10 dígitos nacionales, ej. `3001234567`.
  final String nationalNumber;

  /// Prefijo fijo Colombia (RN-REG-01).
  static const String countryCode = '+57';

  /// Intenta construir un [ColombianPhone] a partir de la entrada del usuario,
  /// que puede traer espacios, guiones o un `+57`/`57` redundante.
  static ({ColombianPhone? value, String? error}) tryParse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return (value: null, error: 'El celular es obligatorio');
    }

    // Solo dígitos.
    var digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');

    // Tolerar que el usuario reescriba el indicativo pese al prefijo fijo.
    if (digits.startsWith('57') && digits.length > 10) {
      digits = digits.substring(2);
    }

    if (digits.length != 10) {
      return (value: null, error: 'El celular debe tener 10 dígitos');
    }
    if (!digits.startsWith('3')) {
      return (value: null, error: 'Un móvil en Colombia inicia en 3');
    }

    return (
      value: ColombianPhone._('$countryCode$digits', digits),
      error: null,
    );
  }

  @override
  String toString() => e164;

  @override
  bool operator ==(Object other) =>
      other is ColombianPhone && other.e164 == e164;

  @override
  int get hashCode => e164.hashCode;
}
