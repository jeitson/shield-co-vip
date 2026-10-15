/// Value object de correo electrónico.
///
/// Centraliza la validación de formato (RF-REG-05) para que ni la UI ni los
/// casos de uso dupliquen regex. Normaliza a minúsculas y recorta espacios.
class Email {
  const Email._(this.value);

  /// Correo normalizado y válido.
  final String value;

  /// Regex pragmática: `local@dominio.tld`. No pretende cubrir el RFC completo
  /// (imposible con regex), solo descartar formatos obviamente inválidos.
  static final RegExp _pattern = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9]'
    r'(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  /// Intenta construir un [Email] validado.
  ///
  /// Devuelve `null` en [error] si es válido; de lo contrario, un mensaje apto
  /// para mostrar bajo el campo.
  static ({Email? value, String? error}) tryParse(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) {
      return (value: null, error: 'El correo es obligatorio');
    }
    if (!_pattern.hasMatch(normalized)) {
      return (value: null, error: 'Correo con formato inválido');
    }
    return (value: Email._(normalized), error: null);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is Email && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
