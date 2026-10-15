/// Value object de contraseña.
///
/// Política MVP: longitud mínima 8 (RN-REG-02). El contrato queda preparado
/// para endurecer la robustez (mayúscula/número/símbolo + 2FA) sin cambiar la
/// firma — pregunta abierta del memory bank §2 / `01-autenticacion.md`.
class Password {
  const Password._(this.value);

  /// Valor crudo validado. Material sensible: nunca loguear.
  final String value;

  /// Longitud mínima exigida (RN-REG-02).
  static const int minLength = 8;

  /// Intenta construir una [Password] válida.
  static ({Password? value, String? error}) tryParse(String raw) {
    if (raw.isEmpty) {
      return (value: null, error: 'La contraseña es obligatoria');
    }
    if (raw.length < minLength) {
      return (
        value: null,
        error: 'La contraseña debe tener al menos $minLength caracteres',
      );
    }
    return (value: Password._(raw), error: null);
  }

  @override
  String toString() => '******'; // Nunca exponer el valor en logs/strings.

  @override
  bool operator ==(Object other) => other is Password && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
