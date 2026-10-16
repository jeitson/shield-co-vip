import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/features/events/domain/entities/event_filter.dart';
import 'package:shield_app/features/events/presentation/state/events_view_state.dart';

/// Controla la búsqueda y el chip de filtro del timeline (síncrono).
final eventsFilterControllerProvider =
    NotifierProvider<EventsFilterController, EventsViewState>(
      EventsFilterController.new,
    );

class EventsFilterController extends Notifier<EventsViewState> {
  @override
  EventsViewState build() => const EventsViewState();

  void setQuery(String value) => state = state.copyWith(query: value);

  void setTypeChip(EventTypeFilter type) =>
      state = state.copyWith(filter: state.filter.withType(type));

  void setLevelChip(EventLevelFilter level) =>
      state = state.copyWith(filter: state.filter.withLevel(level));

  /// Chip "Todos": limpia tipo y severidad (no toca la búsqueda).
  void clearFilter() => state = state.copyWith(filter: EventFilter.all);
}
