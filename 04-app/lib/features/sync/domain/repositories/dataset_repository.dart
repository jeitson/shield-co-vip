import 'package:shield_app/core/error/result.dart';

/// Resultado de una pasada de sincronización.
class SyncOutcome {
  const SyncOutcome({
    required this.currentVersion,
    required this.appliedCount,
    required this.full,
  });

  final int currentVersion;

  /// Firmas afectadas (altas + bajas) aplicadas en esta pasada.
  final int appliedCount;

  final bool full;
}

/// Gestiona el dataset local de hashes y su sincronización con el servidor
/// (`03-datos` §03.4). Es la fuente del contador (RF-SHIELD-06) y del sync
/// manual/automático (RF-SHIELD-07).
abstract interface class DatasetRepository {
  /// Conteo actual de firmas activas en la base local.
  Future<int> countActive();

  /// Stream reactivo del conteo (alimenta el contador del Dashboard).
  Stream<int> watchCountActive();

  /// Ejecuta el delta sync: pide novedades desde `last_synced_version`, verifica
  /// el checksum y aplica altas/bajas. Serializa: una sola sync a la vez.
  Future<Result<SyncOutcome>> syncNow();

  /// Última sincronización exitosa (local), para la UI.
  Future<DateTime?> lastSyncedAt();
}
