import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';

/// Metadatos forenses opcionales del evento (`EventoInterceptado.detalles`).
class EventDetails {
  const EventDetails({
    this.ubicacion,
    this.duracion,
    this.operador,
    this.intentos,
  });

  final String? ubicacion;
  final String? duracion;
  final String? operador;
  final int? intentos;

  Map<String, dynamic> toJson() => {
    if (ubicacion != null) 'ubicacion': ubicacion,
    if (duracion != null) 'duracion': duracion,
    if (operador != null) 'operador': operador,
    if (intentos != null) 'intentos': intentos,
  };

  factory EventDetails.fromJson(Map<String, dynamic> json) => EventDetails(
    ubicacion: json['ubicacion'] as String?,
    duracion: json['duracion'] as String?,
    operador: json['operador'] as String?,
    intentos: json['intentos'] as int?,
  );
}

/// `EventoInterceptado` de `00-fundamentos` §00.2: una llamada o SMS que el
/// motor interceptó. Inmutable y sin dependencias de Flutter/drift.
///
/// Reutiliza los catálogos del motor para no duplicar: [type] (`ContactChannel`),
/// [level] (`ThreatLevel`) y [category] (`ThreatCategory`). La **clasificación**
/// del número (confianza/negra) NO vive aquí: se deriva de la feature `lists`
/// por [sender], para que un cambio se refleje en todos los eventos del mismo
/// número y la exclusividad RN-05 tenga una sola fuente de verdad (spec 03).
class InterceptedEvent {
  const InterceptedEvent({
    required this.id,
    required this.sender,
    required this.type,
    required this.level,
    required this.timestamp,
    required this.threatTitle,
    required this.category,
    required this.reputationTag,
    required this.diagnosis,
    this.quarantinedContent,
    this.details,
  });

  /// Identificador único (ordenable por tiempo).
  final String id;

  /// Remitente en formato canónico E.164 (RN-04).
  final String sender;

  /// Vector del evento (llamada/SMS).
  final ContactChannel type;

  /// Severidad de la amenaza.
  final ThreatLevel level;

  /// Momento del evento (fecha real, RN-04).
  final DateTime timestamp;

  /// Clasificación legible ("Extorsión Carcelaria"…).
  final String threatTitle;

  /// Categoría estructurada (RN-07). Gobierna la elegibilidad SIC.
  final ThreatCategory category;

  /// Origen/razón de la detección.
  final String reputationTag;

  /// Explicación de por qué se interceptó.
  final String diagnosis;

  /// Texto del SMS aislado (solo SMS).
  final String? quarantinedContent;

  /// Metadatos forenses opcionales.
  final EventDetails? details;

  /// Elegible para exportación de evidencia SIC solo si es una violación de la
  /// franja Ley 2300 (RN-CALLS-02, por categoría — no por texto del título).
  bool get isSicEligible => category == ThreatCategory.ley2300;

  /// `true` si debe mostrarse el sandbox de cuarentena (SMS con contenido).
  bool get hasQuarantine =>
      type == ContactChannel.sms &&
      quarantinedContent != null &&
      quarantinedContent!.isNotEmpty;
}
