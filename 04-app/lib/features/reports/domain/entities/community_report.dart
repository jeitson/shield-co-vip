import 'package:shield_app/features/engine/domain/entities/threat_category.dart';

/// Lo que el usuario decide reportar a la comunidad (mínimo y anónimo).
///
/// El `device_id` anónimo de instalación NO vive aquí: lo resuelve la capa de
/// datos desde el `DeviceIdStore`, porque no es una decisión de dominio y el
/// servidor lo valida contra el header `x-device-id` (spec 04, RN-DETAIL-02).
/// El reporte es anónimo respecto al reportante: nunca viaja identidad,
/// contactos, contenido del mensaje ni la nota adicional (RN-02, DA-10).
class CommunityReport {
  const CommunityReport({required this.numero, required this.categoria});

  /// Número del infractor en formato canónico E.164 (RN-04).
  final String numero;

  /// Categoría del problema, del catálogo cerrado RN-07.
  final ThreatCategory categoria;
}
