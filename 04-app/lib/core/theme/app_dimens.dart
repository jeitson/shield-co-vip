/// Tokens de forma y espaciado (`01-docs/06-design-system.md` §6.5).
///
/// Densidad compacta "táctica/forense". Mantener estos valores como única
/// fuente de verdad para radios, paddings y gaps.
abstract final class AppRadii {
  /// Píldoras / badges / switches.
  static const pill = 999.0;

  /// Chips.
  static const chip = 8.0;

  /// Mayoría de tarjetas (rounded-xl).
  static const card = 12.0;

  /// Tarjetas destacadas / modal (rounded-2xl).
  static const cardLarge = 16.0;

  /// Marco emulador (solo referencia de prototipo, no se porta el chrome).
  static const device = 40.0;
}

/// Escala de espaciado derivada de los gaps Tailwind observados.
abstract final class AppSpacing {
  static const xs = 4.0; // gap-1
  static const sm = 8.0; // gap-2
  static const md = 12.0; // gap-3 / p-3
  static const lg = 16.0; // gap-4 / p-4
  static const xl = 24.0;
  static const xxl = 32.0;
}
