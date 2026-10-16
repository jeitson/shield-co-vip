/// Tipo de contacto entrante que evalúa el motor.
enum ContactChannel { call, sms }

/// Contacto entrante a evaluar por el motor de precedencia.
///
/// Para SMS, [body] permite extraer URLs/dominios a verificar (R5). Para
/// llamadas, [body] es `null`.
class IncomingContact {
  const IncomingContact({
    required this.rawNumber,
    required this.channel,
    this.body,
  });

  /// Número crudo tal como lo entrega el SO (se normaliza a E.164 antes de hashear).
  final String rawNumber;

  /// Canal del contacto (llamada o SMS).
  final ContactChannel channel;

  /// Cuerpo del SMS (solo para `sms`); `null` en llamadas.
  final String? body;
}
