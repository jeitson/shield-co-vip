import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/core/secure/pepper_store.dart';
import 'package:shield_app/features/sync/data/datasources/sync_remote_data_source.dart';
import 'package:shield_app/features/sync/data/repositories/pepper_repository_impl.dart';
import 'package:shield_app/features/sync/domain/entities/sync_delta.dart';
import 'package:shield_app/features/sync/domain/repositories/pepper_repository.dart';

/// PepperStore en memoria.
class _MemPepperStore implements PepperStore {
  String? _pepper;
  int? _version;
  @override
  Future<String?> readPepper() async => _pepper;
  @override
  Future<int?> readVersion() async => _version;
  @override
  Future<void> write(String pepper, int version) async {
    _pepper = pepper;
    _version = version;
  }

  @override
  Future<void> clear() async {
    _pepper = null;
    _version = null;
  }
}

/// Remote que cuenta cuántas veces se pidió el pepper.
class _CountingRemote implements SyncRemoteDataSource {
  int pepperCalls = 0;
  @override
  Future<Result<PepperMaterial>> fetchPepper() async {
    pepperCalls++;
    return const Ok(PepperMaterial(pepper: 'remote-pepper', version: 2));
  }

  @override
  Future<Result<SyncDelta>> fetchDelta({
    required int since,
    int? pepperVersion,
  }) async => const Err(NetworkFailure());
}

void main() {
  late _MemPepperStore store;
  late _CountingRemote remote;
  late PepperRepository repo;

  setUp(() {
    store = _MemPepperStore();
    remote = _CountingRemote();
    repo = PepperRepositoryImpl(remote: remote, store: store);
  });

  test(
    'getOrFetchPepper obtiene del remoto y lo persiste la primera vez',
    () async {
      final result = await repo.getOrFetchPepper();
      expect(result.isOk, isTrue);
      expect(remote.pepperCalls, 1);
      expect(await store.readPepper(), 'remote-pepper');
      expect(await store.readVersion(), 2);
    },
  );

  test('getOrFetchPepper reutiliza el keystore sin volver al remoto', () async {
    await store.write('cached', 7);
    final result = await repo.getOrFetchPepper();
    expect(result.isOk, isTrue);
    expect(remote.pepperCalls, 0); // no fue al remoto
    result.fold((m) => expect(m.pepper, 'cached'), (_) => fail('ok esperado'));
  });

  test('clear borra el material local', () async {
    await store.write('x', 1);
    await repo.clear();
    expect(await store.readPepper(), isNull);
  });
}
