/// Lista local a la que puede pertenecer un número.
enum ListKind {
  confianza,
  negra;

  /// Literal persistido en `numeros_listados.lista` (estable; no cambiar).
  String get storageValue => name;

  /// Deserializa desde el texto almacenado; `null` si no se reconoce.
  static ListKind? fromStorage(String? value) {
    for (final k in ListKind.values) {
      if (k.storageValue == value) return k;
    }
    return null;
  }
}

/// Cómo entró un número a una lista (`NumeroListado.origen` de 00-fundamentos).
enum ListOrigin {
  manual,
  evento,
  simulador;

  /// Literal persistido en `numeros_listados.origen`.
  String get storageValue => name;
}

/// Número en una lista local del usuario (`NumeroListado` de 00-fundamentos).
///
/// El número vive en formato canónico E.164 (RN-04); la exclusividad confianza/
/// negra (RN-05) la garantizan el esquema (PK) y el repositorio.
class ListedNumber {
  const ListedNumber({
    required this.numero,
    required this.lista,
    required this.origen,
  });

  /// Número canónico E.164 (o código corto SMS tal cual, RN-04).
  final String numero;

  /// Lista a la que pertenece.
  final ListKind lista;

  /// Origen de la clasificación.
  final ListOrigin origen;
}
