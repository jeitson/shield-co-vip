/// Resultado del último intento de **alta manual** en una lista (confianza o
/// negra) desde la configuración avanzada (spec 05).
///
/// La lista en sí es reactiva (streams de `lists_providers`); este estado solo
/// captura el feedback del formulario de alta para pintar un error bajo el
/// input. Por eso vive en `presentation` y no toca el dominio.
enum AddPhase {
  /// Sin error; el input puede recibir una nueva entrada.
  idle,

  /// La entrada no es un número válido tras normalizar (RN-04).
  invalid,

  /// El número (en su forma canónica) ya está en esta lista (RN-ADV-01/R4).
  duplicate,
}

/// Estado inmutable del alta por lista.
class ListAdminState {
  const ListAdminState({this.phase = AddPhase.idle});

  final AddPhase phase;

  bool get hasError => phase != AddPhase.idle;

  /// Mensaje textual del error (texto redundante, no solo color).
  String? get message => switch (phase) {
    AddPhase.idle => null,
    AddPhase.invalid => 'Número inválido. Revisa el formato.',
    AddPhase.duplicate => 'Ese número ya está en la lista.',
  };

  ListAdminState copyWith({AddPhase? phase}) =>
      ListAdminState(phase: phase ?? this.phase);
}
