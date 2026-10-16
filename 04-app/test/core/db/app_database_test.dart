import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/db/daos/shield_config_dao.dart';

/// Pruebas de esquema/DAOs sobre una base **en memoria** (sin cifrado): validan
/// la lógica de datos. El cifrado real (`PRAGMA cipher`) se verifica aparte en
/// dispositivo/emulador (ver tasks §5.3), ya que requiere el binario sqlite3mc.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('shield_config', () {
    test('nace con las 3 capas activas (RN-SHIELD-04)', () async {
      final cfg = await db.shieldConfigDao.readConfig();
      expect(cfg.extorsion, isTrue);
      expect(cfg.callcenter, isTrue);
      expect(cfg.ley, isTrue);
    });

    test('setLayer persiste el cambio', () async {
      await db.shieldConfigDao.setLayer(ShieldLayer.extorsion, false);
      final cfg = await db.shieldConfigDao.readConfig();
      expect(cfg.extorsion, isFalse);
      expect(cfg.callcenter, isTrue);
      expect(cfg.ley, isTrue);
    });

    test('watchConfig emite el estado actualizado', () async {
      final emissions = <bool>[];
      final sub = db.shieldConfigDao.watchConfig().listen(
        (row) => emissions.add(row.ley),
      );

      await db.shieldConfigDao.setLayer(ShieldLayer.ley, false);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await sub.cancel();
      expect(emissions.last, isFalse);
    });

    test('mantiene una única fila singleton', () async {
      await db.shieldConfigDao.setLayer(ShieldLayer.callcenter, false);
      await db.shieldConfigDao.setLayer(ShieldLayer.callcenter, true);
      final rows = await db.select(db.shieldConfigTable).get();
      expect(rows.length, 1);
    });
  });

  group('phone_hashes', () {
    PhoneHashesTableCompanion row(
      String hash, {
      int added = 1,
      int? removed,
      int pepper = 1,
    }) {
      return PhoneHashesTableCompanion.insert(
        hash: hash,
        categoria: 'Extorsión / amenaza',
        nivel: 'ALTO',
        addedAtVersion: added,
        pepperVersion: pepper,
        removedAtVersion: Value(removed),
      );
    }

    test('countActive ignora las bajas (soft delete)', () async {
      await db.phoneHashesDao.upsertAll([
        row('h1'),
        row('h2'),
        row('h3', removed: 5),
      ]);
      expect(await db.phoneHashesDao.countActive(), 2);
    });

    test('markRemoved da de baja sin borrar la fila', () async {
      await db.phoneHashesDao.upsertAll([row('h1'), row('h2')]);
      await db.phoneHashesDao.markRemoved(['h1'], 7);
      expect(await db.phoneHashesDao.countActive(), 1);
      final all = await db.select(db.phoneHashesTable).get();
      expect(all.length, 2); // h1 sigue en la tabla, solo marcada
    });

    test('activeHashes devuelve el Set para matching O(1)', () async {
      await db.phoneHashesDao.upsertAll([
        row('h1'),
        row('h2'),
        row('h3', removed: 2),
      ]);
      final set = await db.phoneHashesDao.activeHashes();
      expect(set, {'h1', 'h2'});
    });

    test('upsert actualiza una firma existente por hash', () async {
      await db.phoneHashesDao.upsertAll([row('h1', pepper: 1)]);
      await db.phoneHashesDao.upsertAll([row('h1', pepper: 2)]);
      final all = await db.select(db.phoneHashesTable).get();
      expect(all.length, 1);
    });

    test('watchCountActive reacciona a altas y bajas', () async {
      final emissions = <int>[];
      final sub = db.phoneHashesDao.watchCountActive().listen(emissions.add);

      await db.phoneHashesDao.upsertAll([row('h1'), row('h2')]);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await db.phoneHashesDao.markRemoved(['h1'], 3);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await sub.cancel();
      expect(emissions.last, 1);
    });

    test('clearAll vacía el dataset (full-resync)', () async {
      await db.phoneHashesDao.upsertAll([row('h1'), row('h2')]);
      await db.phoneHashesDao.clearAll();
      expect(await db.phoneHashesDao.countActive(), 0);
    });
  });
}
