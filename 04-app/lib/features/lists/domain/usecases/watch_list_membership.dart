import 'package:shield_app/features/lists/domain/canonical_number.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/domain/repositories/lists_repository.dart';

/// Caso de uso: observar a qué lista pertenece un número (confianza/negra/ninguna).
///
/// Normaliza el número (RN-04) para que la consulta coincida con lo almacenado.
/// Alimenta los badges CONFIABLE/BLOQUEADO del timeline (R7.5).
class WatchListMembership {
  const WatchListMembership(this._repository);

  final ListsRepository _repository;

  Stream<ListKind?> call(String rawNumber) {
    final canonical = canonicalizeNumber(rawNumber);
    if (canonical == null) return Stream.value(null);
    return _repository.watchMembership(canonical);
  }
}
