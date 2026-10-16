import 'package:shield_app/core/db/daos/listed_numbers_dao.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/domain/repositories/lists_repository.dart';

/// Implementación de [ListsRepository] sobre [ListedNumbersDao].
///
/// Traduce el enum de dominio [ListKind] a los literales persistidos y confía la
/// atomicidad de la exclusividad (RN-05) a la transacción del DAO. Asume que el
/// número ya llega **canónico** (el caso de uso lo normaliza).
class ListsRepositoryImpl implements ListsRepository {
  ListsRepositoryImpl(this._dao);

  final ListedNumbersDao _dao;

  @override
  Stream<ListKind?> watchMembership(String numero) {
    return _dao.watchMembership(numero).map(ListKind.fromStorage);
  }

  @override
  Future<Result<void>> classify({
    required String numero,
    required ListKind? kind,
    ListOrigin origin = ListOrigin.evento,
  }) async {
    try {
      await _dao.classify(
        numero: numero,
        lista: kind?.storageValue,
        origen: origin.storageValue,
      );
      return const Ok(null);
    } catch (e) {
      return Err(UnknownFailure(message: 'No se pudo clasificar', cause: e));
    }
  }

  @override
  Stream<Set<String>> watchConfianza() =>
      _dao.watchByLista(ListKind.confianza.storageValue);

  @override
  Stream<Set<String>> watchNegra() =>
      _dao.watchByLista(ListKind.negra.storageValue);
}
