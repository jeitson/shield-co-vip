import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/sync/domain/entities/sync_state.dart';
import 'package:shield_app/features/sync/presentation/sync_providers.dart';

/// Estado del sync del dataset para la UI (Dashboard). Expone
/// idle/sincronizando/éxito/error y el método [sync] para el botón manual
/// (RF-SHIELD-07, EST-SHIELD-04/05).
final syncControllerProvider = AsyncNotifierProvider<SyncController, SyncState>(
  SyncController.new,
);

class SyncController extends AsyncNotifier<SyncState> {
  @override
  Future<SyncState> build() async {
    // Estado inicial: inactivo, con la última fecha de sync conocida.
    final repo = await ref.watch(datasetRepositoryProvider.future);
    final lastAt = await repo.lastSyncedAt();
    return SyncIdle(lastSyncedAt: lastAt);
  }

  /// Dispara una sincronización. Refleja los estados en `state`.
  Future<void> sync() async {
    // Evitar relanzar si ya está sincronizando.
    if (state.valueOrNull is SyncInProgress) return;

    final previousAt = _currentLastSyncedAt();
    state = const AsyncData(SyncInProgress());

    final repo = await ref.read(datasetRepositoryProvider.future);
    final result = await repo.syncNow();

    switch (result) {
      case Ok(:final value):
        final at = await repo.lastSyncedAt() ?? DateTime.now();
        state = AsyncData(
          SyncSuccess(syncedAt: at, appliedCount: value.appliedCount),
        );
      case Err(:final failure):
        state = AsyncData(
          SyncFailure(failure: failure, lastSyncedAt: previousAt),
        );
    }
  }

  DateTime? _currentLastSyncedAt() => switch (state.valueOrNull) {
    SyncIdle(:final lastSyncedAt) => lastSyncedAt,
    SyncSuccess(:final syncedAt) => syncedAt,
    SyncFailure(:final lastSyncedAt) => lastSyncedAt,
    _ => null,
  };
}
