import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/db/db_providers.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/events/data/repositories/events_repository_impl.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/domain/event_search.dart';
import 'package:shield_app/features/events/domain/repositories/events_repository.dart';
import 'package:shield_app/features/events/domain/usecases/record_event.dart';
import 'package:shield_app/features/events/presentation/controllers/events_filter_controller.dart';
import 'package:shield_app/features/events/presentation/state/events_view_state.dart';

/// Segundos estimados ahorrados por evento neutralizado (R5, decisión de la spec
/// 03 §4). Constante única y documentada; ajustable sin tocar la UI.
const int kAvgSecondsSavedPerEvent = 45;

// --- Inyección de dependencias ---

/// Repositorio de eventos. Async: depende de la base cifrada.
final eventsRepositoryProvider = FutureProvider<EventsRepository>((ref) async {
  final dao = await ref.watch(eventsDaoProvider.future);
  return EventsRepositoryImpl(dao);
});

/// Historial completo observado (orden fecha desc). Resuelve de forma natural
/// los estados cargando / error / data del timeline (R6.1/6.2).
final eventsStreamProvider = StreamProvider<List<InterceptedEvent>>((ref) async* {
  final repo = await ref.watch(eventsRepositoryProvider.future);
  yield* repo.watchAll();
});

/// Carga un evento por id para el detalle (R10). `null` = no encontrado.
///
/// El detalle forense completo es la spec `04-detalle-evento`; este provider es
/// el enganche de datos para que la navegación `/calls/:id` no quede rota.
final eventByIdProvider = FutureProvider.family<InterceptedEvent?, String>((
  ref,
  id,
) async {
  final repo = await ref.watch(eventsRepositoryProvider.future);
  final result = await repo.getById(id);
  return result.fold((event) => event, (_) => null);
});

/// Acción de inserción (contrato `RecordEvent`): la usan el puente nativo y el
/// Simulador para persistir interceptaciones reales/simuladas (spec 03 §3).
final recordEventProvider = Provider<Future<Result<void>> Function(InterceptedEvent)>(
  (ref) => (event) async {
    final repo = await ref.read(eventsRepositoryProvider.future);
    return RecordEvent(repo).call(event);
  },
);

// --- Derivados de presentación ---

/// Telemetría de las 3 micro-tarjetas, calculada de los eventos reales (R5).
class EventsTelemetry {
  const EventsTelemetry({
    required this.today,
    required this.critical,
    required this.secondsSaved,
  });

  /// Intercepciones de hoy (día local actual).
  final int today;

  /// Críticas = eventos de nivel ALTO.
  final int critical;

  /// Tiempo ahorrado en segundos (nº eventos × constante).
  final int secondsSaved;

  static const empty = EventsTelemetry(today: 0, critical: 0, secondsSaved: 0);
}

/// Deriva la telemetría de la lista observada (reactivo, R5.4).
final telemetryProvider = Provider<EventsTelemetry>((ref) {
  final events = ref.watch(eventsStreamProvider).valueOrNull ?? const [];
  if (events.isEmpty) return EventsTelemetry.empty;

  final now = DateTime.now();
  final dayStart = DateTime(now.year, now.month, now.day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  var today = 0;
  var critical = 0;
  for (final e in events) {
    if (!e.timestamp.isBefore(dayStart) && e.timestamp.isBefore(dayEnd)) {
      today++;
    }
    if (e.level == ThreatLevel.alto) critical++;
  }
  return EventsTelemetry(
    today: today,
    critical: critical,
    secondsSaved: events.length * kAvgSecondsSavedPerEvent,
  );
});

/// Total del historial sin filtrar, para el chip "Todos (N)" (RN-CALLS-05).
final totalEventsCountProvider = Provider<int>((ref) {
  return ref.watch(eventsStreamProvider).valueOrNull?.length ?? 0;
});

/// Resultado del timeline tras aplicar búsqueda + filtro (AND), con la razón del
/// vacío para que la UI elija el estado correcto (R3/R4/R6).
class VisibleEvents {
  const VisibleEvents({required this.events, required this.emptyReason});
  final List<InterceptedEvent> events;
  final EmptyReason emptyReason;
}

/// Lista visible derivada: aplica búsqueda normalizada + filtro de chip (AND) y
/// decide vacío inicial vs. vacío por filtro (R6.3/6.4).
final visibleEventsProvider = Provider<VisibleEvents>((ref) {
  final base = ref.watch(eventsStreamProvider).valueOrNull ?? const [];
  final view = ref.watch(eventsFilterControllerProvider);

  if (base.isEmpty) {
    return const VisibleEvents(events: [], emptyReason: EmptyReason.initial);
  }

  final filtered = base
      .where((e) => view.filter.matches(e) && eventMatchesQuery(e, view.query))
      .toList(growable: false);

  return VisibleEvents(
    events: filtered,
    emptyReason: filtered.isEmpty ? EmptyReason.filtered : EmptyReason.none,
  );
});

/// Tamaño de página del timeline (R12). Se cargan de a [kEventsPageSize] y se
/// amplía bajo scroll, manteniendo búsqueda/filtro coherentes (R12.2) porque la
/// paginación opera **sobre la lista ya filtrada**.
const int kEventsPageSize = 50;

/// Número de eventos actualmente mostrados. Se reinicia al cambiar la búsqueda o
/// el filtro (escuchando `eventsFilterControllerProvider`) para no arrastrar un
/// desplazamiento incoherente entre criterios.
final visiblePageSizeProvider =
    NotifierProvider<VisiblePageSize, int>(VisiblePageSize.new);

class VisiblePageSize extends Notifier<int> {
  @override
  int build() {
    // Reiniciar la ventana al cambiar el criterio de búsqueda/filtro.
    ref.listen(eventsFilterControllerProvider, (_, _) {
      state = kEventsPageSize;
    });
    return kEventsPageSize;
  }

  /// Amplía la ventana en una página más (al llegar al final del scroll).
  void loadMore() => state += kEventsPageSize;
}

/// Página del timeline a renderizar: la lista visible recortada a la ventana
/// actual, más si hay más por cargar (R12).
class PagedEvents {
  const PagedEvents({
    required this.events,
    required this.emptyReason,
    required this.hasMore,
  });
  final List<InterceptedEvent> events;
  final EmptyReason emptyReason;
  final bool hasMore;
}

/// Recorta `visibleEventsProvider` a la ventana de paginación.
final pagedVisibleEventsProvider = Provider<PagedEvents>((ref) {
  final visible = ref.watch(visibleEventsProvider);
  final limit = ref.watch(visiblePageSizeProvider);

  if (visible.emptyReason != EmptyReason.none) {
    return PagedEvents(
      events: const [],
      emptyReason: visible.emptyReason,
      hasMore: false,
    );
  }

  final page = visible.events.take(limit).toList(growable: false);
  return PagedEvents(
    events: page,
    emptyReason: EmptyReason.none,
    hasMore: visible.events.length > page.length,
  );
});
