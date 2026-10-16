import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';

/// Deriva atributos de presentación de un evento (nivel, título, diagnóstico) a
/// partir de su [ThreatCategory]. El nativo solo aporta la **capa/categoría**
/// del bloqueo; aquí se sintetiza el resto para construir el `InterceptedEvent`.
///
/// El mapeo categoría→nivel es la regla de negocio de severidad (spec 03 §4:
/// "críticas = ALTO"). Es ajustable sin tocar la UI.
abstract final class ThreatPresentation {
  /// Nivel de severidad por categoría (RN-07 → ALTO/MEDIO/BAJO).
  static ThreatLevel levelOf(ThreatCategory category) => switch (category) {
    ThreatCategory.extorsion => ThreatLevel.alto,
    ThreatCategory.phishing => ThreatLevel.alto,
    ThreatCategory.callcenter => ThreatLevel.medio,
    ThreatCategory.llamadaFantasma => ThreatLevel.medio,
    ThreatCategory.ley2300 => ThreatLevel.bajo,
    ThreatCategory.comercial => ThreatLevel.bajo,
  };

  /// Título legible de la amenaza por categoría.
  static String titleOf(ThreatCategory category) => switch (category) {
    ThreatCategory.extorsion => 'Extorsión / amenaza',
    ThreatCategory.phishing => 'Phishing / suplantación',
    ThreatCategory.callcenter => 'Call center / discador',
    ThreatCategory.llamadaFantasma => 'Llamada fantasma',
    ThreatCategory.ley2300 => 'Violación franja Ley 2300',
    ThreatCategory.comercial => 'Comercial sin riesgo',
  };

  /// Etiqueta de reputación/origen de la detección.
  static String reputationTagOf(ThreatCategory category) => switch (category) {
    ThreatCategory.extorsion => 'Número peligroso (comunidad)',
    ThreatCategory.phishing => 'Suplantación detectada',
    ThreatCategory.callcenter => 'Discador robótico',
    ThreatCategory.llamadaFantasma => 'Llamada silenciosa',
    ThreatCategory.ley2300 => 'Ley 2300 aplicada',
    ThreatCategory.comercial => 'Contacto comercial',
  };

  /// Diagnóstico corto por categoría (por qué se interceptó).
  static String diagnosisOf(ThreatCategory category) => switch (category) {
    ThreatCategory.extorsion =>
      'Coincide con una firma de extorsión de la lista comunitaria.',
    ThreatCategory.phishing =>
      'Patrón de suplantación/phishing detectado por el motor local.',
    ThreatCategory.callcenter =>
      'Identificado como call center o discador automático.',
    ThreatCategory.llamadaFantasma =>
      'Llamada silenciosa o fantasma neutralizada.',
    ThreatCategory.ley2300 =>
      'Contacto comercial fuera de la franja horaria legal (Ley 2300).',
    ThreatCategory.comercial => 'Contacto comercial sin riesgo aparente.',
  };

  /// Capa (`extorsion`/`callcenter`/`ley`) → categoría representativa, cuando el
  /// nativo solo pudo aportar la capa responsable del bloqueo y no la categoría
  /// exacta. Se elige la categoría "cabecera" de esa capa.
  static ThreatCategory categoryForLayer(String? layer) => switch (layer) {
    'extorsion' => ThreatCategory.extorsion,
    'callcenter' => ThreatCategory.callcenter,
    'ley' => ThreatCategory.ley2300,
    _ => ThreatCategory.comercial, // local / desconocida → sin riesgo aparente
  };
}
