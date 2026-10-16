import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';

/// Dimensión de tipo del chip de filtro (RF-CALLS-03).
enum EventTypeFilter { all, call, sms }

/// Dimensión de severidad del chip de filtro (RF-CALLS-03).
enum EventLevelFilter { all, alto, medio, bajo }

/// Filtro activo del timeline. El prototipo presenta los chips como una fila de
/// opciones mutuamente excluyentes ("Todos", Llamadas, SMS, Alto, Medio, Bajo):
/// seleccionar un chip de tipo fija `level=all` y viceversa. "Todos" = ambos en
/// `all`.
class EventFilter {
  const EventFilter({this.type = EventTypeFilter.all, this.level = EventLevelFilter.all});

  final EventTypeFilter type;
  final EventLevelFilter level;

  static const all = EventFilter();

  /// Chip de tipo: fija el tipo y limpia la severidad (exclusividad del chip).
  EventFilter withType(EventTypeFilter t) =>
      EventFilter(type: t, level: EventLevelFilter.all);

  /// Chip de severidad: fija el nivel y limpia el tipo.
  EventFilter withLevel(EventLevelFilter l) =>
      EventFilter(type: EventTypeFilter.all, level: l);

  bool get isAll =>
      type == EventTypeFilter.all && level == EventLevelFilter.all;

  /// Aplica el filtro a un evento (RF-CALLS-03).
  bool matches(InterceptedEvent e) {
    final typeOk = switch (type) {
      EventTypeFilter.all => true,
      EventTypeFilter.call => e.type == ContactChannel.call,
      EventTypeFilter.sms => e.type == ContactChannel.sms,
    };
    final levelOk = switch (level) {
      EventLevelFilter.all => true,
      EventLevelFilter.alto => e.level == ThreatLevel.alto,
      EventLevelFilter.medio => e.level == ThreatLevel.medio,
      EventLevelFilter.bajo => e.level == ThreatLevel.bajo,
    };
    return typeOk && levelOk;
  }

  @override
  bool operator ==(Object other) =>
      other is EventFilter && other.type == type && other.level == level;

  @override
  int get hashCode => Object.hash(type, level);
}
