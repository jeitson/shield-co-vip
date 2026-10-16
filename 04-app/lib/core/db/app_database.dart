import 'package:drift/drift.dart';
import 'package:shield_app/core/db/daos/events_dao.dart';
import 'package:shield_app/core/db/daos/listed_numbers_dao.dart';
import 'package:shield_app/core/db/daos/phone_hashes_dao.dart';
import 'package:shield_app/core/db/daos/shield_config_dao.dart';
import 'package:shield_app/core/db/tables/intercepted_events_table.dart';
import 'package:shield_app/core/db/tables/listed_numbers_table.dart';
import 'package:shield_app/core/db/tables/phone_hashes_table.dart';
import 'package:shield_app/core/db/tables/shield_config_table.dart';

part 'app_database.g.dart';

/// Base de datos local **cifrada** de Cifrado Cero (drift + SQLite3MultipleCiphers,
/// `04-app-flutter` §04.4, `02-seguridad` §02.3).
///
/// Se abre siempre con la DEK del keystore (ver `encrypted_database.dart`); el
/// constructor recibe el ejecutor ya configurado para no acoplar el esquema al
/// mecanismo de cifrado (facilita tests con `NativeDatabase.memory`).
///
/// Esquema:
/// - **v1**: `shield_config` (3 capas, singleton) y `phone_hashes` (dataset local).
/// - **v2**: añade `eventos` (historial interceptado) y `numeros_listados`
///   (listas confianza/negra, exclusividad RN-05) — feature `events` + `lists`
///   (spec 03). La migración v1→v2 es **no destructiva**: solo crea las tablas
///   nuevas, sin tocar los datos existentes.
@DriftDatabase(
  tables: [
    ShieldConfigTable,
    PhoneHashesTable,
    InterceptedEventsTable,
    ListedNumbersTable,
  ],
  daos: [ShieldConfigDao, PhoneHashesDao, EventsDao, ListedNumbersDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Semilla de la fila singleton con las 3 capas activas (RN-SHIELD-04).
      await into(shieldConfigTable).insert(
        const ShieldConfigTableCompanion(id: Value(1)),
        mode: InsertMode.insertOrIgnore,
      );
    },
    onUpgrade: (m, from, to) async {
      // v1 → v2: crea solo las tablas nuevas de la spec 03 (no destructivo).
      if (from < 2) {
        await m.createTable(interceptedEventsTable);
        await m.createTable(listedNumbersTable);
      }
    },
    beforeOpen: (details) async {
      // Integridad referencial activa para futuras tablas relacionadas.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
