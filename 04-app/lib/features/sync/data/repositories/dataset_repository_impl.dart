import 'dart:async';

import 'package:drift/drift.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/db/daos/phone_hashes_dao.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/sync/data/datasources/sync_metadata_store.dart';
import 'package:shield_app/features/sync/data/datasources/sync_remote_data_source.dart';
import 'package:shield_app/features/sync/data/sync_checksum.dart';
import 'package:shield_app/features/sync/domain/entities/sync_delta.dart';
import 'package:shield_app/features/sync/domain/repositories/dataset_repository.dart';
import 'package:shield_app/features/sync/domain/repositories/pepper_repository.dart';

/// Implementación de [DatasetRepository]: delta sync real con verificación de
/// integridad y aplicación a la base local vía [PhoneHashesDao].
class DatasetRepositoryImpl implements DatasetRepository {
  DatasetRepositoryImpl({
    required this.remote,
    required this.dao,
    required this.metadata,
    required this.pepper,
  });

  final SyncRemoteDataSource remote;
  final PhoneHashesDao dao;
  final SyncMetadataStore metadata;
  final PepperRepository pepper;

  /// Serializa el sync: si ya hay uno en curso, se reutiliza su futuro (R7.4).
  Future<Result<SyncOutcome>>? _inFlight;

  @override
  Future<int> countActive() => dao.countActive();

  @override
  Stream<int> watchCountActive() => dao.watchCountActive();

  @override
  Future<DateTime?> lastSyncedAt() => metadata.lastSyncedAt();

  @override
  Future<Result<SyncOutcome>> syncNow() {
    // De-dup: una sola sync a la vez.
    return _inFlight ??= _runSync().whenComplete(() => _inFlight = null);
  }

  Future<Result<SyncOutcome>> _runSync() async {
    // 1) Asegurar el pepper (necesario para que el servidor hashee con el mismo;
    //    aquí sirve para enviar pepper_version y detectar rotación).
    final pepperResult = await pepper.getOrFetchPepper();
    final localPepperVersion = switch (pepperResult) {
      Ok(:final value) => value.version,
      Err() => null, // sin pepper: pedimos delta sin pepper_version
    };

    // 2) Pedir el delta desde la última versión aplicada.
    final since = await metadata.lastSyncedVersion();
    final deltaResult = await remote.fetchDelta(
      since: since,
      pepperVersion: localPepperVersion,
    );

    return switch (deltaResult) {
      Err(:final failure) => Err(failure),
      Ok(:final value) => await _applyDelta(value, localPepperVersion),
    };
  }

  Future<Result<SyncOutcome>> _applyDelta(
    SyncDelta delta,
    int? localPepperVersion,
  ) async {
    // 3) Verificar integridad antes de tocar la base (02-seguridad §02.6).
    if (!SyncChecksum.verify(delta)) {
      return const Err(IntegrityFailure());
    }

    // 4) Si cambió el pepper, refrescarlo en keystore (full-resync coherente).
    if (localPepperVersion != null &&
        delta.pepperVersion != localPepperVersion) {
      await pepper.refreshPepper();
    }

    // 5) Aplicar a la base local.
    final altas = delta.altas.map(_toCompanion).toList();
    if (delta.full) {
      await dao.clearAll();
      await dao.upsertAll(altas);
    } else {
      if (altas.isNotEmpty) await dao.upsertAll(altas);
      if (delta.bajas.isNotEmpty) {
        await dao.markRemoved(delta.bajas, delta.currentVersion);
      }
    }

    // 6) Persistir metadatos.
    final now = DateTime.now();
    await metadata.save(version: delta.currentVersion, at: now);

    return Ok(
      SyncOutcome(
        currentVersion: delta.currentVersion,
        appliedCount: delta.altas.length + delta.bajas.length,
        full: delta.full,
      ),
    );
  }

  PhoneHashesTableCompanion _toCompanion(HashSignature h) {
    return PhoneHashesTableCompanion.insert(
      hash: h.hash,
      categoria: h.categoria,
      nivel: h.nivel,
      addedAtVersion: 1,
      // El servidor ya filtra activos; localmente las altas entran activas.
      removedAtVersion: const Value(null),
      pepperVersion: 1,
    );
  }
}
