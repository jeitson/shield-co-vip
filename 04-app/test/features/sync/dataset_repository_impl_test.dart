import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/sync/data/datasources/sync_metadata_store.dart';
import 'package:shield_app/features/sync/data/datasources/sync_remote_data_source.dart';
import 'package:shield_app/features/sync/data/repositories/dataset_repository_impl.dart';
import 'package:shield_app/features/sync/data/sync_checksum.dart';
import 'package:shield_app/features/sync/domain/entities/sync_delta.dart';
import 'package:shield_app/features/sync/domain/repositories/pepper_repository.dart';

/// Remote falso: devuelve el delta/pepper que se le configura, sin red.
class _FakeRemote implements SyncRemoteDataSource {
  _FakeRemote(this._delta);
  SyncDelta _delta;
  int fetchCount = 0;

  void setDelta(SyncDelta d) => _delta = d;

  @override
  Future<Result<SyncDelta>> fetchDelta({
    required int since,
    int? pepperVersion,
  }) async {
    fetchCount++;
    return Ok(_delta);
  }

  @override
  Future<Result<PepperMaterial>> fetchPepper() async =>
      const Ok(PepperMaterial(pepper: 'p', version: 1));
}

/// Pepper falso con versión fija.
class _FakePepper implements PepperRepository {
  int refreshCount = 0;
  @override
  Future<Result<PepperMaterial>> getOrFetchPepper() async =>
      const Ok(PepperMaterial(pepper: 'p', version: 1));
  @override
  Future<Result<PepperMaterial>> refreshPepper() async {
    refreshCount++;
    return const Ok(PepperMaterial(pepper: 'p', version: 1));
  }

  @override
  Future<void> clear() async {}
}

/// Metadata store en memoria.
class _MemMetadata implements SyncMetadataStore {
  int _version = 0;
  DateTime? _at;
  @override
  Future<int> lastSyncedVersion() async => _version;
  @override
  Future<DateTime?> lastSyncedAt() async => _at;
  @override
  Future<void> save({required int version, required DateTime at}) async {
    _version = version;
    _at = at;
  }

  @override
  Future<void> clear() async {
    _version = 0;
    _at = null;
  }
}

/// Construye un [SyncDelta] con checksum válido (coherente con el servidor).
SyncDelta validDelta({
  required int currentVersion,
  required List<HashSignature> altas,
  List<String> bajas = const [],
  bool full = false,
  int pepperVersion = 1,
}) {
  final base = SyncDelta(
    currentVersion: currentVersion,
    pepperVersion: pepperVersion,
    altas: altas,
    bajas: bajas,
    checksum: '',
    full: full,
  );
  // Recomputar el checksum real sobre el mismo payload.
  final checksum = SyncChecksum.compute(base);
  return SyncDelta(
    currentVersion: currentVersion,
    pepperVersion: pepperVersion,
    altas: altas,
    bajas: bajas,
    checksum: checksum,
    full: full,
  );
}

void main() {
  late AppDatabase db;
  late _FakeRemote remote;
  late _FakePepper pepper;
  late _MemMetadata metadata;
  late DatasetRepositoryImpl repo;

  HashSignature sig(String h) =>
      HashSignature(hash: h, categoria: 'Extorsión / amenaza', nivel: 'ALTO');

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remote = _FakeRemote(validDelta(currentVersion: 1, altas: [sig('h1')]));
    pepper = _FakePepper();
    metadata = _MemMetadata();
    repo = DatasetRepositoryImpl(
      remote: remote,
      dao: db.phoneHashesDao,
      metadata: metadata,
      pepper: pepper,
    );
  });

  tearDown(() => db.close());

  test('full sync inserta todas las altas y actualiza la versión', () async {
    remote.setDelta(
      validDelta(
        currentVersion: 5,
        altas: [sig('h1'), sig('h2'), sig('h3')],
        full: true,
      ),
    );
    final result = await repo.syncNow();
    expect(result.isOk, isTrue);
    expect(await repo.countActive(), 3);
    expect(await metadata.lastSyncedVersion(), 5);
  });

  test('delta aplica altas y bajas (soft delete)', () async {
    // Primer full con h1, h2.
    remote.setDelta(
      validDelta(currentVersion: 1, altas: [sig('h1'), sig('h2')], full: true),
    );
    await repo.syncNow();

    // Delta: alta h3, baja h1.
    remote.setDelta(
      validDelta(currentVersion: 2, altas: [sig('h3')], bajas: ['h1']),
    );
    final result = await repo.syncNow();

    expect(result.isOk, isTrue);
    // h2 + h3 activos (h1 dado de baja).
    expect(await repo.countActive(), 2);
    final set = await db.phoneHashesDao.activeHashes();
    expect(set, {'h2', 'h3'});
  });

  test('checksum inválido NO aplica y devuelve IntegrityFailure', () async {
    final corrupted = SyncDelta(
      currentVersion: 9,
      pepperVersion: 1,
      altas: [sig('h1')],
      bajas: const [],
      checksum: 'sha256:deadbeef', // no coincide
      full: true,
    );
    remote.setDelta(corrupted);

    final result = await repo.syncNow();
    expect(result.isErr, isTrue);
    result.fold(
      (_) => fail('debía fallar'),
      (f) => expect(f, isA<IntegrityFailure>()),
    );
    // La base no se tocó.
    expect(await repo.countActive(), 0);
    expect(await metadata.lastSyncedVersion(), 0);
  });

  test('syncs concurrentes se de-duplican (una sola petición)', () async {
    remote.setDelta(
      validDelta(currentVersion: 1, altas: [sig('h1')], full: true),
    );
    final f1 = repo.syncNow();
    final f2 = repo.syncNow();
    await Future.wait([f1, f2]);
    // Ambas comparten la misma pasada → una sola llamada remota.
    expect(remote.fetchCount, 1);
  });

  test('watchCountActive refleja el total tras aplicar el delta', () async {
    remote.setDelta(
      validDelta(currentVersion: 1, altas: [sig('h1'), sig('h2')], full: true),
    );
    await repo.syncNow();
    expect(await repo.watchCountActive().first, 2);
  });
}
