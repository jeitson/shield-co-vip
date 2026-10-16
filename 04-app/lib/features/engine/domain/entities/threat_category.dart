/// Capa de protección del escudo responsable de una categoría de amenaza.
enum ShieldLayerKind { extorsion, callcenter, ley }

/// Catálogo cerrado de categorías de amenaza (RN-07) y su capa responsable.
///
/// El servidor envía `categoria` como texto (mismo literal que el seed). Este
/// enum lo normaliza y resuelve qué capa del escudo la gobierna, para que
/// desactivar una capa deje pasar su categoría (RN-SHIELD-05).
enum ThreatCategory {
  extorsion('Extorsión / amenaza', ShieldLayerKind.extorsion),
  phishing('Phishing / vishing (suplantación)', ShieldLayerKind.extorsion),
  callcenter('Call center / discador robótico', ShieldLayerKind.callcenter),
  llamadaFantasma('Llamada fantasma / silenciosa', ShieldLayerKind.callcenter),
  ley2300('Violación franja Ley 2300', ShieldLayerKind.ley),
  comercial('Comercial sin riesgo', ShieldLayerKind.ley);

  const ThreatCategory(this.label, this.layer);

  /// Literal tal como lo envía el servidor / seed.
  final String label;

  /// Capa del escudo que gobierna esta categoría (RN-07).
  final ShieldLayerKind layer;

  /// Resuelve la categoría desde el texto del servidor; `null` si no se reconoce.
  static ThreatCategory? fromLabel(String label) {
    for (final c in ThreatCategory.values) {
      if (c.label == label) return c;
    }
    return null;
  }
}
