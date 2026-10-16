import 'package:equatable/equatable.dart';
import 'package:shield_app/core/error/failure.dart';

/// Estado observable de la sincronización del dataset, para la UI del Dashboard
/// (EST-SHIELD-04 sincronizando, EST-SHIELD-05 error). Modela los estados
/// obligatorios del dominio (`00-fundamentos` §00.5).
sealed class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// Sin sincronización en curso. Puede traer la fecha de la última sync exitosa.
class SyncIdle extends SyncState {
  const SyncIdle({this.lastSyncedAt});

  final DateTime? lastSyncedAt;

  @override
  List<Object?> get props => [lastSyncedAt];
}

/// Sincronización en curso ("Verificando firmas…").
class SyncInProgress extends SyncState {
  const SyncInProgress();
}

/// Sincronización terminada con éxito.
class SyncSuccess extends SyncState {
  const SyncSuccess({required this.syncedAt, required this.appliedCount});

  final DateTime syncedAt;

  /// Nº de firmas afectadas (altas + bajas) en esta pasada; informativo.
  final int appliedCount;

  @override
  List<Object?> get props => [syncedAt, appliedCount];
}

/// Sincronización fallida (red, servidor o integridad). Conserva la última
/// fecha exitosa para no borrarla de la UI (CA-SHIELD-07).
class SyncFailure extends SyncState {
  const SyncFailure({required this.failure, this.lastSyncedAt});

  final Failure failure;
  final DateTime? lastSyncedAt;

  @override
  List<Object?> get props => [failure, lastSyncedAt];
}
