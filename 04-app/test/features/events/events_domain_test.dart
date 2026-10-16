import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/events/domain/entities/event_filter.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/domain/event_search.dart';
import 'package:shield_app/features/events/presentation/controllers/events_filter_controller.dart';
import 'package:shield_app/features/events/presentation/events_providers.dart';
import 'package:shield_app/features/events/presentation/state/events_view_state.dart';

InterceptedEvent _event({
  required String id,
  String sender = '+573001234567',
  ContactChannel type = ContactChannel.call,
  ThreatLevel level = ThreatLevel.alto,
  ThreatCategory category = ThreatCategory.extorsion,
  String threatTitle = 'Amenaza',
  String reputationTag = 'VoIP no registrado',
  String diagnosis = 'Patrón sospechoso',
  String? quarantined,
  DateTime? at,
}) {
  return InterceptedEvent(
    id: id,
    sender: sender,
    type: type,
    level: level,
    timestamp: at ?? DateTime(2026, 1, 1, 12),
    threatTitle: threatTitle,
    category: category,
    reputationTag: reputationTag,
    diagnosis: diagnosis,
    quarantinedContent: quarantined,
  );
}

/// Construye un container con el stream de eventos sobredimensionado.
ProviderContainer _containerWith(List<InterceptedEvent> events) {
  return ProviderContainer(
    overrides: [
      eventsStreamProvider.overrideWith((ref) => Stream.value(events)),
    ],
  );
}

void main() {
  group('InterceptedEvent', () {
    test('isSicEligible solo para categoría Ley 2300 (RN-CALLS-02)', () {
      expect(
        _event(id: 'a', category: ThreatCategory.ley2300).isSicEligible,
        isTrue,
      );
      expect(
        _event(id: 'b', category: ThreatCategory.extorsion).isSicEligible,
        isFalse,
      );
    });

    test('hasQuarantine solo en SMS con contenido', () {
      expect(
        _event(id: 'a', type: ContactChannel.sms, quarantined: 'hola')
            .hasQuarantine,
        isTrue,
      );
      expect(
        _event(id: 'b', type: ContactChannel.call, quarantined: 'hola')
            .hasQuarantine,
        isFalse,
      );
      expect(
        _event(id: 'c', type: ContactChannel.sms).hasQuarantine,
        isFalse,
      );
    });
  });

  group('búsqueda (RF-CALLS-02)', () {
    test('coincide insensible a mayúsculas y acentos', () {
      final e = _event(id: 'a', threatTitle: 'Extorsión Carcelaria');
      expect(eventMatchesQuery(e, 'extorsion'), isTrue);
      expect(eventMatchesQuery(e, 'CARCEL'), isTrue);
      expect(eventMatchesQuery(e, 'phishing'), isFalse);
    });

    test('query vacío coincide con todo', () {
      expect(eventMatchesQuery(_event(id: 'a'), '   '), isTrue);
    });
  });

  group('visibleEventsProvider (R3/R4/R6)', () {
    test('vacío inicial cuando no hay eventos', () {
      final c = _containerWith([]);
      addTearDown(c.dispose);
      // forzar primer valor del stream
      c.read(eventsStreamProvider);
      final visible = c.read(visibleEventsProvider);
      expect(visible.emptyReason, EmptyReason.initial);
    });

    test('filtro + búsqueda se aplican en AND', () async {
      final c = _containerWith([
        _event(id: 'sms-ext', type: ContactChannel.sms, threatTitle: 'Phishing'),
        _event(id: 'call-ext', type: ContactChannel.call, threatTitle: 'Phishing'),
        _event(id: 'sms-otro', type: ContactChannel.sms, threatTitle: 'Promo'),
      ]);
      addTearDown(c.dispose);
      await c.read(eventsStreamProvider.future);

      c.read(eventsFilterControllerProvider.notifier)
        ..setTypeChip(EventTypeFilter.sms)
        ..setQuery('phishing');

      final visible = c.read(visibleEventsProvider);
      expect(visible.events.map((e) => e.id), ['sms-ext']);
      expect(visible.emptyReason, EmptyReason.none);
    });

    test('vacío por filtro cuando hay base pero nada coincide', () async {
      final c = _containerWith([_event(id: 'a', threatTitle: 'Extorsión')]);
      addTearDown(c.dispose);
      await c.read(eventsStreamProvider.future);

      c.read(eventsFilterControllerProvider.notifier).setQuery('inexistente');

      expect(c.read(visibleEventsProvider).emptyReason, EmptyReason.filtered);
    });
  });

  group('paginación (R12)', () {
    List<InterceptedEvent> many(int n) => List.generate(
      n,
      (i) => _event(
        id: 'e$i',
        at: DateTime(2026, 1, 1, 12).subtract(Duration(minutes: i)),
      ),
    );

    test('recorta a la primera página y marca hasMore', () async {
      final c = _containerWith(many(kEventsPageSize + 10));
      addTearDown(c.dispose);
      await c.read(eventsStreamProvider.future);

      final paged = c.read(pagedVisibleEventsProvider);
      expect(paged.events.length, kEventsPageSize);
      expect(paged.hasMore, isTrue);
    });

    test('loadMore amplía la ventana', () async {
      final c = _containerWith(many(kEventsPageSize + 10));
      addTearDown(c.dispose);
      await c.read(eventsStreamProvider.future);

      c.read(visiblePageSizeProvider.notifier).loadMore();
      final paged = c.read(pagedVisibleEventsProvider);
      expect(paged.events.length, kEventsPageSize + 10);
      expect(paged.hasMore, isFalse);
    });

    test('cambiar la búsqueda reinicia la ventana', () async {
      final c = _containerWith(many(kEventsPageSize + 10));
      addTearDown(c.dispose);
      await c.read(eventsStreamProvider.future);

      c.read(visiblePageSizeProvider.notifier).loadMore();
      expect(c.read(visiblePageSizeProvider), kEventsPageSize * 2);

      c.read(eventsFilterControllerProvider.notifier).setQuery('x');
      expect(c.read(visiblePageSizeProvider), kEventsPageSize);
    });

    test('sin exceso de eventos no hay más por cargar', () async {
      final c = _containerWith(many(5));
      addTearDown(c.dispose);
      await c.read(eventsStreamProvider.future);

      final paged = c.read(pagedVisibleEventsProvider);
      expect(paged.events.length, 5);
      expect(paged.hasMore, isFalse);
    });
  });

  group('telemetryProvider (R5)', () {
    test('críticas cuenta ALTO; tiempo ahorrado usa la constante', () async {
      final c = _containerWith([
        _event(id: 'a', level: ThreatLevel.alto),
        _event(id: 'b', level: ThreatLevel.alto),
        _event(id: 'c', level: ThreatLevel.bajo),
      ]);
      addTearDown(c.dispose);
      await c.read(eventsStreamProvider.future);

      final t = c.read(telemetryProvider);
      expect(t.critical, 2);
      expect(t.secondsSaved, 3 * kAvgSecondsSavedPerEvent);
    });

    test('intercepciones de hoy cuenta solo el día local actual', () async {
      final now = DateTime.now();
      final c = _containerWith([
        _event(id: 'hoy', at: DateTime(now.year, now.month, now.day, 9)),
        _event(id: 'viejo', at: DateTime(2020, 1, 1)),
      ]);
      addTearDown(c.dispose);
      await c.read(eventsStreamProvider.future);

      expect(c.read(telemetryProvider).today, 1);
    });
  });
}
