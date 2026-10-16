import 'package:drift/drift.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/db/tables/phone_hashes_table.dart';

part 'phone_hashes_dao.g.dart';

/// Acceso tipado al dataset local de hashes (`phone_hashes`).
///
/// Lo **escribe** `features/sync` (altas/bajas del delta) y lo **lee** el motor
/// de bloqueo (matching) y el Dashboard (contador). Una firma está *activa* si
/// `removedAtVersion IS NULL` (soft delete para propagar bajas).
@DriftAccessor(tables: [PhoneHashesTable])
class PhoneHashesDao extends DatabaseAccessor<AppDatabase>
    with _$PhoneHashesDaoMixin {
  PhoneHashesDao(super.db);

  /// Conteo de firmas activas (RF-SHIELD-06). `COUNT` en SQL, sin cargar filas.
  Future<int> countActive() async {
    final count = phoneHashesTable.hash.count();
    final query = selectOnly(phoneHashesTable)
      ..addColumns([count])
      ..where(phoneHashesTable.removedAtVersion.isNull());
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Observa el conteo de firmas activas para la UI reactiva del contador.
  Stream<int> watchCountActive() {
    final count = phoneHashesTable.hash.count();
    final query = selectOnly(phoneHashesTable)
      ..addColumns([count])
      ..where(phoneHashesTable.removedAtVersion.isNull());
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Devuelve los hashes activos como `Set` para el matching O(1) del motor
  /// (`04-app-flutter` §04.4).
  Future<Set<String>> activeHashes() async {
    final query = selectOnly(phoneHashesTable)
      ..addColumns([phoneHashesTable.hash])
      ..where(phoneHashesTable.removedAtVersion.isNull());
    final rows = await query.get();
    return rows.map((r) => r.read(phoneHashesTable.hash)!).toSet();
  }

  /// Mapa `hash → categoria` de las firmas activas, para que el motor resuelva
  /// qué capa del escudo gobierna cada amenaza (RN-07 / RN-SHIELD-05).
  Future<Map<String, String>> activeCategoryByHash() async {
    final query = selectOnly(phoneHashesTable)
      ..addColumns([phoneHashesTable.hash, phoneHashesTable.categoria])
      ..where(phoneHashesTable.removedAtVersion.isNull());
    final rows = await query.get();
    return {
      for (final r in rows)
        r.read(phoneHashesTable.hash)!: r.read(phoneHashesTable.categoria)!,
    };
  }

  /// Aplica un lote de **altas/actualizaciones** (upsert por `hash`).
  /// Usado por el delta sync al aplicar las novedades del servidor.
  Future<void> upsertAll(Iterable<PhoneHashesTableCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(phoneHashesTable, rows.toList());
    });
  }

  /// Marca como **baja** (soft delete) los hashes dados en [removedAtVersion].
  Future<void> markRemoved(
    Iterable<String> hashes,
    int removedAtVersion,
  ) async {
    await batch((b) {
      for (final h in hashes) {
        b.update(
          phoneHashesTable,
          PhoneHashesTableCompanion(removedAtVersion: Value(removedAtVersion)),
          where: (t) => t.hash.equals(h),
        );
      }
    });
  }

  /// Borra todo el dataset local (full-resync por rotación de pepper o gap
  /// grande, `03-datos` §03.4).
  Future<void> clearAll() => delete(phoneHashesTable).go();
}
