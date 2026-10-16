import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/lists/domain/canonical_number.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/domain/repositories/lists_repository.dart';
import 'package:shield_app/features/lists/domain/usecases/classify_number.dart';

/// Repositorio falso en memoria con exclusividad RN-05 real, para ejercitar el
/// caso de uso sin base de datos.
class _FakeListsRepository implements ListsRepository {
  final Map<String, ListKind> _store = {};
  String? lastClassifiedNumero;

  @override
  Future<Result<void>> classify({
    required String numero,
    required ListKind? kind,
    ListOrigin origin = ListOrigin.evento,
  }) async {
    lastClassifiedNumero = numero;
    if (kind == null) {
      _store.remove(numero);
    } else {
      _store[numero] = kind; // PK por número → exclusividad
    }
    return const Ok(null);
  }

  @override
  Stream<ListKind?> watchMembership(String numero) =>
      Stream.value(_store[numero]);

  @override
  Stream<Set<String>> watchConfianza() => Stream.value(
        _store.entries
            .where((e) => e.value == ListKind.confianza)
            .map((e) => e.key)
            .toSet(),
      );

  @override
  Stream<Set<String>> watchNegra() => Stream.value(
        _store.entries
            .where((e) => e.value == ListKind.negra)
            .map((e) => e.key)
            .toSet(),
      );
}

void main() {
  group('canonicalizeNumber (RN-04)', () {
    test('móvil CO con espacios/guiones → E.164', () {
      expect(canonicalizeNumber('300 123 4567'), '+573001234567');
      expect(canonicalizeNumber('+57 300-123-4567'), '+573001234567');
      expect(canonicalizeNumber('573001234567'), '+573001234567');
    });

    test('código corto / remitente no-móvil se conserva recortado', () {
      expect(canonicalizeNumber('890123'), '890123');
      expect(canonicalizeNumber('  BANCO  '), 'BANCO');
    });

    test('vacío → null', () {
      expect(canonicalizeNumber('   '), isNull);
    });
  });

  group('ClassifyNumber', () {
    test('normaliza a E.164 antes de delegar', () async {
      final repo = _FakeListsRepository();
      final usecase = ClassifyNumber(repo);

      await usecase('300 123 4567', ListKind.negra);

      expect(repo.lastClassifiedNumero, '+573001234567');
    });

    test('exclusividad RN-05: pasar de confianza a negra no deja duplicado',
        () async {
      final repo = _FakeListsRepository();
      final usecase = ClassifyNumber(repo);

      await usecase('+573001234567', ListKind.confianza);
      await usecase('+573001234567', ListKind.negra);

      final confianza = await repo.watchConfianza().first;
      final negra = await repo.watchNegra().first;
      expect(confianza, isEmpty);
      expect(negra, {'+573001234567'});
    });

    test('kind null desmarca el número', () async {
      final repo = _FakeListsRepository();
      final usecase = ClassifyNumber(repo);

      await usecase('+573001234567', ListKind.negra);
      await usecase('+573001234567', null);

      expect(await repo.watchNegra().first, isEmpty);
    });

    test('número inválido devuelve Err sin tocar el repositorio', () async {
      final repo = _FakeListsRepository();
      final usecase = ClassifyNumber(repo);

      final result = await usecase('   ', ListKind.negra);

      expect(result.isErr, isTrue);
      expect(repo.lastClassifiedNumero, isNull);
    });
  });
}
