import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/sync/domain/repositories/dataset_repository.dart';

/// Caso de uso: sincronizar el dataset ahora (thin wrapper sobre el repo).
///
/// Mantiene la presentación libre de detalles del repositorio y da un punto
/// único para encadenar reglas futuras (p. ej. no sincronizar sin sesión).
class SyncDataset {
  const SyncDataset(this._repo);

  final DatasetRepository _repo;

  Future<Result<SyncOutcome>> call() => _repo.syncNow();
}
