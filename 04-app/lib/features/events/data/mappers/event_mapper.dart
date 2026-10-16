import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';

/// Conversión fila ↔ entidad para el historial de eventos. Centraliza la
/// (de)serialización de los enums y de los metadatos forenses (`detailsJson`).
abstract final class EventMapper {
  // --- Row → entidad ---

  static InterceptedEvent toEntity(InterceptedEventRow row) {
    return InterceptedEvent(
      id: row.id,
      sender: row.sender,
      type: _channelFromStorage(row.type),
      level: _levelFromStorage(row.level),
      timestamp: row.timestamp,
      threatTitle: row.threatTitle,
      category: ThreatCategory.fromLabel(row.category) ?? _fallbackCategory,
      reputationTag: row.reputationTag,
      diagnosis: row.diagnosis,
      quarantinedContent: row.quarantinedContent,
      details: _detailsFromJson(row.detailsJson),
    );
  }

  // --- Entidad → companion (insert/upsert) ---

  static InterceptedEventsTableCompanion toCompanion(InterceptedEvent e) {
    return InterceptedEventsTableCompanion.insert(
      id: e.id,
      sender: e.sender,
      type: e.type.name, // 'call' | 'sms'
      level: e.level.label, // 'ALTO' | 'MEDIO' | 'BAJO'
      timestamp: e.timestamp,
      threatTitle: e.threatTitle,
      category: e.category.label,
      reputationTag: e.reputationTag,
      diagnosis: e.diagnosis,
      quarantinedContent: Value(e.quarantinedContent),
      detailsJson: Value(
        e.details == null ? null : jsonEncode(e.details!.toJson()),
      ),
    );
  }

  // --- Helpers de enums ---

  /// Categoría de respaldo si el `label` almacenado no se reconoce (p. ej. un
  /// dataset futuro con una categoría nueva): se trata como comercial (BAJO).
  static const _fallbackCategory = ThreatCategory.comercial;

  static ContactChannel _channelFromStorage(String v) =>
      v == ContactChannel.sms.name ? ContactChannel.sms : ContactChannel.call;

  static ThreatLevel _levelFromStorage(String v) => switch (v) {
    'ALTO' => ThreatLevel.alto,
    'MEDIO' => ThreatLevel.medio,
    _ => ThreatLevel.bajo,
  };

  static EventDetails? _detailsFromJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return EventDetails.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null; // metadatos corruptos: no romper el timeline
    }
  }
}
