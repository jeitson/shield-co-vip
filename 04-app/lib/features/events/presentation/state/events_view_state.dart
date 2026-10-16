import 'package:shield_app/features/events/domain/entities/event_filter.dart';

/// Estado de vista del timeline: término de búsqueda + chip de filtro activo.
/// Es el input de presentación; la lista resultante se deriva aparte.
class EventsViewState {
  const EventsViewState({this.query = '', this.filter = EventFilter.all});

  final String query;
  final EventFilter filter;

  EventsViewState copyWith({String? query, EventFilter? filter}) =>
      EventsViewState(
        query: query ?? this.query,
        filter: filter ?? this.filter,
      );
}

/// Por qué la lista visible está vacía (gobierna qué estado vacío pintar).
enum EmptyReason {
  /// No hay ningún evento en el historial (bienvenida, EST-CALLS-03).
  initial,

  /// Hay eventos pero el filtro/búsqueda no arroja resultados (EST-CALLS-02).
  filtered,

  /// La lista visible no está vacía.
  none,
}
