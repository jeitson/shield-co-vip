import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/db/db_providers.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/lists/data/repositories/lists_repository_impl.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/domain/repositories/lists_repository.dart';
import 'package:shield_app/features/lists/domain/usecases/classify_number.dart';

/// Repositorio de listas locales. Async porque depende de la base cifrada
/// (`listedNumbersDaoProvider` es un `FutureProvider`).
final listsRepositoryProvider = FutureProvider<ListsRepository>((ref) async {
  final dao = await ref.watch(listedNumbersDaoProvider.future);
  return ListsRepositoryImpl(dao);
});

/// Caso de uso de clasificación (set/unset con exclusividad RN-05).
///
/// Se expone como acción: resuelve el repo y delega. Normaliza a E.164 (RN-04)
/// dentro de [ClassifyNumber].
final classifyNumberProvider = Provider<_ClassifyNumberAction>((ref) {
  return _ClassifyNumberAction(ref);
});

class _ClassifyNumberAction {
  _ClassifyNumberAction(this._ref);
  final Ref _ref;

  Future<Result<void>> call(
    String rawNumber,
    ListKind? kind, {
    ListOrigin origin = ListOrigin.evento,
  }) async {
    try {
      final repo = await _ref.read(listsRepositoryProvider.future);
      return await ClassifyNumber(repo).call(rawNumber, kind, origin: origin);
    } catch (e) {
      return Err(UnknownFailure(message: 'Listas no disponibles', cause: e));
    }
  }
}

/// Observa la pertenencia de un número a una lista (badges del timeline, R7.5).
///
/// `family` por número canónico. Mientras el repo se resuelve, emite `null`
/// (sin badge), lo que es un estado válido (número no clasificado aún).
final membershipProvider = StreamProvider.family<ListKind?, String>((
  ref,
  numero,
) async* {
  final repo = await ref.watch(listsRepositoryProvider.future);
  yield* repo.watchMembership(numero);
});

/// Conjuntos reactivos para el motor (números crudos; el puente los hashea).
final confianzaNumbersProvider = StreamProvider<Set<String>>((ref) async* {
  final repo = await ref.watch(listsRepositoryProvider.future);
  yield* repo.watchConfianza();
});

final negraNumbersProvider = StreamProvider<Set<String>>((ref) async* {
  final repo = await ref.watch(listsRepositoryProvider.future);
  yield* repo.watchNegra();
});
