import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/lists/domain/canonical_number.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/domain/repositories/lists_repository.dart';

/// Caso de uso: clasificar un número en confianza/negra con exclusividad (RN-05),
/// o desmarcarlo (`kind == null`).
///
/// Normaliza el número a su forma canónica (RN-04) antes de delegar, para que la
/// deduplicación y la exclusividad operen sobre el mismo identificador en todos
/// los eventos del número.
class ClassifyNumber {
  const ClassifyNumber(this._repository);

  final ListsRepository _repository;

  Future<Result<void>> call(
    String rawNumber,
    ListKind? kind, {
    ListOrigin origin = ListOrigin.evento,
  }) {
    final canonical = canonicalizeNumber(rawNumber);
    if (canonical == null) {
      return Future.value(const Err(ServerFailure('Número inválido')));
    }
    return _repository.classify(numero: canonical, kind: kind, origin: origin);
  }
}
