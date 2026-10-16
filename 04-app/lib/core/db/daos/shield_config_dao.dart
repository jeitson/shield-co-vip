import 'package:drift/drift.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/db/tables/shield_config_table.dart';

part 'shield_config_dao.g.dart';

/// Las tres capas del escudo. Espeja `ConfigEscudo` de `00-fundamentos` y evita
/// strings mágicos al alternar una capa concreta.
enum ShieldLayer { extorsion, callcenter, ley }

/// Acceso tipado a la configuración del escudo (fila singleton `id = 1`).
///
/// Expone un **stream** para que el Dashboard reaccione a cambios (RN-SHIELD-01)
/// y un `setLayer` que persiste de forma atómica (RF-SHIELD-02/05).
@DriftAccessor(tables: [ShieldConfigTable])
class ShieldConfigDao extends DatabaseAccessor<AppDatabase>
    with _$ShieldConfigDaoMixin {
  ShieldConfigDao(super.db);

  static const _singletonId = 1;

  /// Observa la configuración actual (defecto: 3 capas activas, RN-SHIELD-04).
  ///
  /// Es un stream **puro de solo lectura**: NO escribe en la base dentro del
  /// stream (hacerlo provocaba re-emisiones en cascada que bloqueaban el hilo
  /// de UI). La fila singleton la siembra la migración `onCreate`; si por lo que
  /// fuera no existiera aún, se emite un valor por defecto en memoria y la
  /// escritura perezosa la hace `readConfig`/`setLayer` cuando corresponda.
  Stream<ShieldConfigRow> watchConfig() {
    final query = select(shieldConfigTable)
      ..where((t) => t.id.equals(_singletonId));
    return query.watchSingleOrNull().map((row) => row ?? _defaultRow());
  }

  /// Valor por defecto en memoria (3 capas activas) para no bloquear la UI si la
  /// fila aún no se materializó.
  ShieldConfigRow _defaultRow() => ShieldConfigRow(
    id: _singletonId,
    extorsion: true,
    callcenter: true,
    ley: true,
    updatedAt: DateTime.now(),
  );

  /// Lee la configuración actual (creando la fila por defecto si falta).
  Future<ShieldConfigRow> readConfig() async {
    await _ensureSingleton();
    return (select(
      shieldConfigTable,
    )..where((t) => t.id.equals(_singletonId))).getSingle();
  }

  /// Activa/desactiva una [layer] y actualiza `updatedAt`.
  Future<void> setLayer(ShieldLayer layer, bool enabled) async {
    await _ensureSingleton();
    final companion = switch (layer) {
      ShieldLayer.extorsion => ShieldConfigTableCompanion(
        extorsion: Value(enabled),
      ),
      ShieldLayer.callcenter => ShieldConfigTableCompanion(
        callcenter: Value(enabled),
      ),
      ShieldLayer.ley => ShieldConfigTableCompanion(ley: Value(enabled)),
    };
    await (update(shieldConfigTable)..where((t) => t.id.equals(_singletonId)))
        .write(companion.copyWith(updatedAt: Value(DateTime.now())));
  }

  /// Inserta la fila singleton con los defectos si aún no existe.
  Future<void> _ensureSingleton() async {
    await into(shieldConfigTable).insert(
      const ShieldConfigTableCompanion(id: Value(_singletonId)),
      mode: InsertMode.insertOrIgnore,
    );
  }
}
