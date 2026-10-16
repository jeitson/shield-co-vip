import 'package:drift/drift.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/db/tables/listed_numbers_table.dart';

part 'listed_numbers_dao.g.dart';

/// Acceso tipado a las listas locales (`numeros_listados`).
///
/// Aplica la **exclusividad RN-05**: un número está en una sola lista a la vez.
/// Como [numero] es PK, reclasificar es un upsert; `classify` encapsula el
/// set/unset de forma atómica. El motor de bloqueo lee `watchByLista` para
/// poblar sus niveles 1 (confianza) y 3 (negra).
///
/// Los literales de lista (`confianza`/`negra`) y de origen los define el
/// dominio (`ListKind`/`ListOrigin`); el DAO los recibe ya serializados como
/// texto para no acoplar `core/db` a una feature.
@DriftAccessor(tables: [ListedNumbersTable])
class ListedNumbersDao extends DatabaseAccessor<AppDatabase>
    with _$ListedNumbersDaoMixin {
  ListedNumbersDao(super.db);

  /// Observa la lista a la que pertenece [numero]; `null` si no está en ninguna.
  Stream<String?> watchMembership(String numero) {
    final query = select(listedNumbersTable)
      ..where((t) => t.numero.equals(numero));
    return query.watchSingleOrNull().map((row) => row?.lista);
  }

  /// Lee la lista de [numero] una vez; `null` si no está listado.
  Future<String?> membership(String numero) async {
    final query = select(listedNumbersTable)
      ..where((t) => t.numero.equals(numero));
    final row = await query.getSingleOrNull();
    return row?.lista;
  }

  /// Clasifica [numero] en [lista] con exclusividad (RN-05), de forma atómica.
  ///
  /// - [lista] no nulo: upsert por `numero` → mueve/crea en esa lista (retira de
  ///   la otra por ser la misma PK).
  /// - [lista] `null`: desmarca (borra la fila del número).
  Future<void> classify({
    required String numero,
    required String? lista,
    required String origen,
  }) async {
    await transaction(() async {
      if (lista == null) {
        await (delete(
          listedNumbersTable,
        )..where((t) => t.numero.equals(numero))).go();
        return;
      }
      await into(listedNumbersTable).insertOnConflictUpdate(
        ListedNumbersTableCompanion.insert(
          numero: numero,
          lista: lista,
          origen: origen,
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  /// Conjunto de números de una lista dada, para el motor (matching O(1)).
  Future<Set<String>> numbersIn(String lista) async {
    final query = selectOnly(listedNumbersTable)
      ..addColumns([listedNumbersTable.numero])
      ..where(listedNumbersTable.lista.equals(lista));
    final rows = await query.get();
    return rows.map((r) => r.read(listedNumbersTable.numero)!).toSet();
  }

  /// Observa el conjunto de números de una lista (fuente reactiva del motor).
  Stream<Set<String>> watchByLista(String lista) {
    final query = selectOnly(listedNumbersTable)
      ..addColumns([listedNumbersTable.numero])
      ..where(listedNumbersTable.lista.equals(lista));
    return query.watch().map(
      (rows) => rows.map((r) => r.read(listedNumbersTable.numero)!).toSet(),
    );
  }
}
