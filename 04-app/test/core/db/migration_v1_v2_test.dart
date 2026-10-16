import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Verifica la migración **v1 → v2** (spec 03, R1.3): abrir una base con el
/// esquema v1 (solo `shield_config` + `phone_hashes`) y datos, y comprobar que
/// `onUpgrade` crea las tablas nuevas (`eventos`, `numeros_listados`) **sin
/// perder** los datos previos. Usa un archivo temporal porque la migración
/// necesita persistir `user_version` entre conexiones (una base en memoria no
/// sobrevive al cierre).
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('cc_mig_test');
    dbFile = File('${tempDir.path}/v1.db');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('v1 → v2 crea las tablas nuevas y conserva los datos v1', () async {
    // 1) Construye a mano una base con el esquema v1 y datos.
    final raw = sqlite3.open(dbFile.path);
    raw.execute('''
      CREATE TABLE shield_config (
        id INTEGER NOT NULL DEFAULT 1 PRIMARY KEY,
        extorsion INTEGER NOT NULL DEFAULT 1,
        callcenter INTEGER NOT NULL DEFAULT 1,
        ley INTEGER NOT NULL DEFAULT 1,
        updated_at INTEGER NOT NULL
      );
      CREATE TABLE phone_hashes (
        hash TEXT NOT NULL PRIMARY KEY,
        categoria TEXT NOT NULL,
        nivel TEXT NOT NULL,
        added_at_version INTEGER NOT NULL,
        removed_at_version INTEGER,
        pepper_version INTEGER NOT NULL
      );
    ''');
    final ts = DateTime(2026).millisecondsSinceEpoch ~/ 1000;
    raw.execute(
      'INSERT INTO shield_config (id, extorsion, callcenter, ley, updated_at) '
      'VALUES (1, 1, 0, 1, $ts);',
    );
    raw.execute(
      'INSERT INTO phone_hashes '
      '(hash, categoria, nivel, added_at_version, pepper_version) '
      "VALUES ('h_legacy', 'Extorsión / amenaza', 'ALTO', 1, 1);",
    );
    raw.userVersion = 1; // marca el esquema como v1 → disparará onUpgrade.
    raw.close();

    // 2) Abre con AppDatabase (schemaVersion 2) → ejecuta onUpgrade.
    final db = AppDatabase(NativeDatabase(dbFile));
    addTearDown(db.close);

    // 3) Datos v1 conservados.
    final cfg = await db.shieldConfigDao.readConfig();
    expect(cfg.callcenter, isFalse, reason: 'dato v1 conservado');
    expect(await db.phoneHashesDao.countActive(), 1);

    // 4) Tablas v2 creadas y utilizables.
    expect(await db.eventsDao.getById('nope'), isNull);
    expect(await db.listedNumbersDao.membership('x'), isNull);
    expect(db.schemaVersion, 2);
  });
}
