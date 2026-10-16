import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/domain/repositories/lists_repository.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';
import 'package:shield_app/features/settings/presentation/widgets/list_manager_card.dart';
import 'package:shield_app/features/settings/presentation/widgets/number_chip.dart';

class _FakeListsRepository implements ListsRepository {
  final Map<String, ListKind> store = {};
  String? lastRemoved;

  @override
  Future<Result<void>> classify({
    required String numero,
    required ListKind? kind,
    ListOrigin origin = ListOrigin.evento,
  }) async {
    if (kind == null) {
      store.remove(numero);
      lastRemoved = numero;
    } else {
      store[numero] = kind;
    }
    return const Ok(null);
  }

  @override
  Stream<ListKind?> watchMembership(String numero) => Stream.value(store[numero]);
  @override
  Stream<Set<String>> watchConfianza() => Stream.value(const {});
  @override
  Stream<Set<String>> watchNegra() =>
      Stream.value(store.keys.toSet());
}

Widget _harness({
  required Set<String> negra,
  _FakeListsRepository? repo,
}) {
  return ProviderScope(
    overrides: [
      negraNumbersProvider.overrideWith((ref) => Stream.value(negra)),
      confianzaNumbersProvider.overrideWith((ref) => Stream.value(const {})),
      if (repo != null)
        listsRepositoryProvider.overrideWith((ref) async => repo),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ListManagerCard(
            kind: ListKind.negra,
            title: 'Lista negra',
            addLabel: 'Bloquear',
            accentColor: Color(0xFFFFB4AB),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('lista vacía muestra el estado vacío', (tester) async {
    await tester.pumpWidget(_harness(negra: const {}));
    await tester.pump();

    expect(find.textContaining('Aún no has añadido'), findsOneWidget);
    expect(find.byType(NumberChip), findsNothing);
  });

  testWidgets('con items muestra N chips y el contador N', (tester) async {
    await tester.pumpWidget(
      _harness(negra: const {'+573001234567', '890123'}),
    );
    await tester.pump();

    expect(find.byType(NumberChip), findsNWidgets(2));
    expect(find.text('2'), findsOneWidget);
    expect(find.text('+573001234567'), findsOneWidget);
    expect(find.text('890123'), findsOneWidget);
  });

  testWidgets('tocar la X de un chip dispara la baja', (tester) async {
    final repo = _FakeListsRepository();
    repo.store['+573001234567'] = ListKind.negra;

    await tester.pumpWidget(
      _harness(negra: const {'+573001234567'}, repo: repo),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(repo.lastRemoved, '+573001234567');
  });

  testWidgets('entrada inválida muestra error bajo el input', (tester) async {
    await tester.pumpWidget(_harness(negra: const {}));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '+++');
    await tester.tap(find.text('Bloquear'));
    await tester.pump();

    expect(find.textContaining('Número inválido'), findsOneWidget);
  });
}
