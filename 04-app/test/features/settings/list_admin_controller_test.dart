import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/domain/repositories/lists_repository.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';
import 'package:shield_app/features/settings/presentation/controllers/list_admin_controller.dart';
import 'package:shield_app/features/settings/presentation/state/list_admin_state.dart';

/// Repositorio falso reactivo: la exclusividad RN-05 (PK por número) y los
/// streams reflejan el store, de modo que `confianza/negraNumbersProvider`
/// reemiten tras cada clasificación (necesario para el chequeo de duplicado).
class _FakeListsRepository implements ListsRepository {
  final Map<String, ListKind> store = {};
  final _confianza = StreamController<Set<String>>.broadcast();
  final _negra = StreamController<Set<String>>.broadcast();

  void dispose() {
    _confianza.close();
    _negra.close();
  }

  void _emit() {
    _confianza.add(_by(ListKind.confianza));
    _negra.add(_by(ListKind.negra));
  }

  Set<String> _by(ListKind kind) => store.entries
      .where((e) => e.value == kind)
      .map((e) => e.key)
      .toSet();

  @override
  Future<Result<void>> classify({
    required String numero,
    required ListKind? kind,
    ListOrigin origin = ListOrigin.evento,
  }) async {
    if (kind == null) {
      store.remove(numero);
    } else {
      store[numero] = kind; // exclusividad por PK
    }
    _emit();
    return const Ok(null);
  }

  @override
  Stream<ListKind?> watchMembership(String numero) => Stream.value(store[numero]);

  @override
  Stream<Set<String>> watchConfianza() async* {
    yield _by(ListKind.confianza);
    yield* _confianza.stream;
  }

  @override
  Stream<Set<String>> watchNegra() async* {
    yield _by(ListKind.negra);
    yield* _negra.stream;
  }
}

ProviderContainer _container(_FakeListsRepository lists) {
  final c = ProviderContainer(
    overrides: [
      listsRepositoryProvider.overrideWith((ref) async => lists),
    ],
  );
  addTearDown(c.dispose);
  addTearDown(lists.dispose);
  return c;
}

void main() {
  test('entrada inválida → AddPhase.invalid y no clasifica', () async {
    final lists = _FakeListsRepository();
    final container = _container(lists);

    final notifier =
        container.read(listAdminControllerProvider(ListKind.negra).notifier);
    final added = await notifier.add('   ');

    expect(added, isFalse);
    expect(
      container.read(listAdminControllerProvider(ListKind.negra)).phase,
      AddPhase.invalid,
    );
    expect(lists.store, isEmpty);
  });

  test('alta válida en negra con origin manual → idle y persiste E.164',
      () async {
    final lists = _FakeListsRepository();
    final container = _container(lists);
    // Prime el provider de la lista (deduplicación lee su future).
    await container.read(negraNumbersProvider.future);

    final notifier =
        container.read(listAdminControllerProvider(ListKind.negra).notifier);
    final added = await notifier.add('300 123 4567');

    expect(added, isTrue);
    expect(lists.store['+573001234567'], ListKind.negra);
    expect(
      container.read(listAdminControllerProvider(ListKind.negra)).phase,
      AddPhase.idle,
    );
  });

  test('duplicado por forma canónica → AddPhase.duplicate', () async {
    final lists = _FakeListsRepository();
    lists.store['+573001234567'] = ListKind.negra; // ya presente
    final container = _container(lists);
    await container.read(negraNumbersProvider.future);

    final notifier =
        container.read(listAdminControllerProvider(ListKind.negra).notifier);
    // Mismo número con otro formato → misma forma canónica.
    final added = await notifier.add('+57 300-123-4567');

    expect(added, isFalse);
    expect(
      container.read(listAdminControllerProvider(ListKind.negra)).phase,
      AddPhase.duplicate,
    );
  });

  test('clearError vuelve a idle', () async {
    final lists = _FakeListsRepository();
    final container = _container(lists);

    final notifier =
        container.read(listAdminControllerProvider(ListKind.negra).notifier);
    await notifier.add('   '); // deja invalid
    expect(
      container.read(listAdminControllerProvider(ListKind.negra)).phase,
      AddPhase.invalid,
    );

    notifier.clearError();
    expect(
      container.read(listAdminControllerProvider(ListKind.negra)).phase,
      AddPhase.idle,
    );
  });

  test('exclusividad RN-05 en alta manual: negra ← número en confianza lo mueve',
      () async {
    final lists = _FakeListsRepository();
    lists.store['+573001234567'] = ListKind.confianza;
    final container = _container(lists);
    await container.read(negraNumbersProvider.future);

    final notifier =
        container.read(listAdminControllerProvider(ListKind.negra).notifier);
    final added = await notifier.add('+573001234567');

    expect(added, isTrue);
    expect(lists.store['+573001234567'], ListKind.negra);
    expect(lists.store.values.where((v) => v == ListKind.confianza), isEmpty);
  });
}
