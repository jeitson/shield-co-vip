import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/core/secure/pepper_store.dart';
import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/engine/data/hmac_hasher.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/engine/domain/precedence_engine.dart';
import 'package:shield_app/features/engine/presentation/engine_providers.dart';
import 'package:shield_app/features/events/data/native_event_queue.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/domain/repositories/events_repository.dart';
import 'package:shield_app/features/events/presentation/events_providers.dart';
import 'package:shield_app/features/events/presentation/intercepted_events_bridge.dart';
import 'package:shield_app/features/sync/presentation/sync_providers.dart';

/// Cola nativa fake: devuelve raws fijos una sola vez (como si drenara).
class _FakeQueue extends NativeEventQueue {
  _FakeQueue(this._raws) : super(null);
  List<RawInterceptedEvent> _raws;

  @override
  Future<List<RawInterceptedEvent>> drain() async {
    final out = _raws;
    _raws = const [];
    return out;
  }
}

/// Pepper fake fijo.
class _FakePepper extends PepperStore {
  _FakePepper(this._p) : super(const FlutterSecureStorage());
  final String? _p;
  @override
  Future<String?> readPepper() async => _p;
}

/// Repo de eventos en memoria para capturar lo persistido.
class _MemEventsRepo implements EventsRepository {
  final List<InterceptedEvent> recorded = [];

  @override
  Stream<List<InterceptedEvent>> watchAll() => Stream.value(recorded);

  @override
  Future<Result<InterceptedEvent?>> getById(String id) async =>
      Ok(recorded.where((e) => e.id == id).firstOrNull);

  @override
  Future<Result<void>> record(InterceptedEvent event) async {
    recorded.add(event);
    return const Ok(null);
  }
}

EngineIndex _indexWith(Map<String, ThreatCategory> byHash) => EngineIndex(
  whitelistLocal: const {},
  blacklistLocal: const {},
  allowlistGlobal: const {},
  blacklistGlobal: byHash.keys.toSet(),
  categoryByHash: byHash,
  config: const EngineShieldConfig(extorsion: true, callcenter: true, ley: true),
);

void main() {
  test('rehidrata categoría por hash del dataset y persiste (call)', () async {
    const pepper = 'p1';
    const number = '+573001112233';
    final hash = HmacHasher.hash(pepper: pepper, numberE164: number);
    final repo = _MemEventsRepo();

    final container = ProviderContainer(
      overrides: [
        nativeEventQueueProvider.overrideWithValue(
          _FakeQueue([
            RawInterceptedEvent(
              rawNumber: '300 111 2233',
              channel: ContactChannel.call,
              layer: 'extorsion',
              timestamp: DateTime(2026, 2, 1, 10),
            ),
          ]),
        ),
        pepperStoreProvider.overrideWithValue(_FakePepper(pepper)),
        engineIndexProvider.overrideWith(
          (ref) async => _indexWith({hash: ThreatCategory.extorsion}),
        ),
        eventsRepositoryProvider.overrideWith((ref) async => repo),
      ],
    );
    addTearDown(container.dispose);

    final n = await container.read(drainInterceptedEventsProvider)();

    expect(n, 1);
    expect(repo.recorded.length, 1);
    final e = repo.recorded.single;
    expect(e.sender, number); // normalizado a E.164
    expect(e.category, ThreatCategory.extorsion); // desde el dataset
    expect(e.level, ThreatLevel.alto);
    expect(e.type, ContactChannel.call);
  });

  test('sin pepper usa la capa del nativo para la categoría (sms + cuarentena)',
      () async {
    final repo = _MemEventsRepo();

    final container = ProviderContainer(
      overrides: [
        nativeEventQueueProvider.overrideWithValue(
          _FakeQueue([
            RawInterceptedEvent(
              rawNumber: '890123',
              channel: ContactChannel.sms,
              layer: 'ley',
              body: 'Oferta fuera de horario',
              timestamp: DateTime(2026, 2, 1, 22),
            ),
          ]),
        ),
        pepperStoreProvider.overrideWithValue(_FakePepper(null)),
        engineIndexProvider.overrideWith((ref) async => _indexWith({})),
        eventsRepositoryProvider.overrideWith((ref) async => repo),
      ],
    );
    addTearDown(container.dispose);

    final n = await container.read(drainInterceptedEventsProvider)();

    expect(n, 1);
    final e = repo.recorded.single;
    expect(e.sender, '890123'); // código corto conservado
    expect(e.category, ThreatCategory.ley2300); // desde la capa 'ley'
    expect(e.isSicEligible, isTrue);
    expect(e.type, ContactChannel.sms);
    expect(e.quarantinedContent, 'Oferta fuera de horario');
    expect(e.hasQuarantine, isTrue);
  });

  test('cola vacía no persiste nada', () async {
    final repo = _MemEventsRepo();
    final container = ProviderContainer(
      overrides: [
        nativeEventQueueProvider.overrideWithValue(_FakeQueue(const [])),
        pepperStoreProvider.overrideWithValue(_FakePepper('p')),
        engineIndexProvider.overrideWith((ref) async => _indexWith({})),
        eventsRepositoryProvider.overrideWith((ref) async => repo),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(drainInterceptedEventsProvider)(), 0);
    expect(repo.recorded, isEmpty);
  });
}
