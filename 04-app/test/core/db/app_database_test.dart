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

  group('eventos (spec 03)', () {
    InterceptedEventsTableCompanion event(
      String id, {
      required DateTime at,
      String sender = '+573001234567',
      String type = 'call',
      String level = 'ALTO',
      String category = 'Extorsión / amenaza',
    }) {
      return InterceptedEventsTableCompanion.insert(
        id: id,
        sender: sender,
        type: type,
        level: level,
        timestamp: at,
        threatTitle: 'Amenaza',
        category: category,
        reputationTag: 'VoIP no registrado',
        diagnosis: 'Patrón sospechoso',
      );
    }

    test('watchAll ordena por fecha descendente (RF-CALLS-01)', () async {
      final base = DateTime(2026, 1, 1, 12);
      await db.eventsDao.insertOne(event('a', at: base));
      await db.eventsDao.insertOne(
        event('b', at: base.add(const Duration(hours: 2))),
      );
      await db.eventsDao.insertOne(
        event('c', at: base.subtract(const Duration(hours: 1))),
      );

      final list = await db.eventsDao.watchAll().first;
      expect(list.map((e) => e.id).toList(), ['b', 'a', 'c']);
    });

    test('getById devuelve el evento o null', () async {
      await db.eventsDao.insertOne(event('x', at: DateTime(2026)));
      expect((await db.eventsDao.getById('x'))?.id, 'x');
      expect(await db.eventsDao.getById('nope'), isNull);
    });

    test('insertOne es idempotente por id (upsert)', () async {
      await db.eventsDao.insertOne(event('dup', at: DateTime(2026)));
      await db.eventsDao.insertOne(
        event('dup', at: DateTime(2026), level: 'BAJO'),
      );
      final all = await db.select(db.interceptedEventsTable).get();
      expect(all.length, 1);
      expect(all.single.level, 'BAJO');
    });

    test('countBetween cuenta la ventana del día (R5)', () async {
      final dayStart = DateTime(2026, 2, 10);
      final dayEnd = dayStart.add(const Duration(days: 1));
      await db.eventsDao.insertOne(
        event('hoy1', at: dayStart.add(const Duration(hours: 9))),
      );
      await db.eventsDao.insertOne(
        event('hoy2', at: dayStart.add(const Duration(hours: 20))),
      );
      await db.eventsDao.insertOne(
        event('ayer', at: dayStart.subtract(const Duration(hours: 1))),
      );

      expect(await db.eventsDao.countBetween(dayStart, dayEnd), 2);
    });

    test('countByLevel cuenta las críticas (ALTO)', () async {
      await db.eventsDao.insertOne(event('a', at: DateTime(2026), level: 'ALTO'));
      await db.eventsDao.insertOne(event('b', at: DateTime(2026), level: 'ALTO'));
      await db.eventsDao.insertOne(event('c', at: DateTime(2026), level: 'BAJO'));
      expect(await db.eventsDao.countByLevel('ALTO'), 2);
    });
  });

  group('numeros_listados · exclusividad RN-05 (spec 03)', () {
    const num1 = '+573001234567';

    test('classify añade a una lista y se observa', () async {
      await db.listedNumbersDao.classify(
        numero: num1,
        lista: 'negra',
        origen: 'evento',
      );
      expect(await db.listedNumbersDao.membership(num1), 'negra');
    });

    test('reclasificar mueve de lista sin dejar duplicado (RN-05)', () async {
      await db.listedNumbersDao.classify(
        numero: num1,
        lista: 'confianza',
        origen: 'manual',
      );
      await db.listedNumbersDao.classify(
        numero: num1,
        lista: 'negra',
        origen: 'evento',
      );

      expect(await db.listedNumbersDao.membership(num1), 'negra');
      final rows = await db.select(db.listedNumbersTable).get();
      expect(rows.length, 1); // una sola fila: nunca en ambas listas
    });

    test('classify con lista null desmarca el número', () async {
      await db.listedNumbersDao.classify(
        numero: num1,
        lista: 'negra',
        origen: 'evento',
      );
      await db.listedNumbersDao.classify(
        numero: num1,
        lista: null,
        origen: 'evento',
      );
      expect(await db.listedNumbersDao.membership(num1), isNull);
    });

    test('watchByLista expone el Set para el motor', () async {
      await db.listedNumbersDao.classify(
        numero: num1,
        lista: 'negra',
        origen: 'evento',
      );
      await db.listedNumbersDao.classify(
        numero: '+573009998877',
        lista: 'negra',
        origen: 'evento',
      );
      await db.listedNumbersDao.classify(
        numero: '+573001112233',
        lista: 'confianza',
        origen: 'manual',
      );

      final negra = await db.listedNumbersDao.watchByLista('negra').first;
      expect(negra, {num1, '+573009998877'});
    });
  });

  group('esquema v2 (coexistencia, R1.3)', () {
    test('schemaVersion es 2', () {
      expect(db.schemaVersion, 2);
    });

    test('las 4 tablas coexisten sin interferir', () async {
      // v1: config + dataset.
      await db.shieldConfigDao.setLayer(ShieldLayer.ley, false);
      await db.phoneHashesDao.upsertAll([
        PhoneHashesTableCompanion.insert(
          hash: 'hh1',
          categoria: 'Extorsión / amenaza',
          nivel: 'ALTO',
          addedAtVersion: 1,
          pepperVersion: 1,
        ),
      ]);
      // v2: eventos + listas.
      await db.eventsDao.insertOne(
        InterceptedEventsTableCompanion.insert(
          id: 'e1',
          sender: '+573001234567',
          type: 'sms',
          level: 'MEDIO',
          timestamp: DateTime(2026, 3, 1),
          threatTitle: 'Phishing',
          category: 'Phishing / vishing (suplantación)',
          reputationTag: 'Dominio sospechoso',
          diagnosis: 'Link acortado',
        ),
      );
      await db.listedNumbersDao.classify(
        numero: '+573001234567',
        lista: 'negra',
        origen: 'evento',
      );

      expect((await db.shieldConfigDao.readConfig()).ley, isFalse);
      expect(await db.phoneHashesDao.countActive(), 1);
      expect((await db.eventsDao.getById('e1'))?.type, 'sms');
      expect(
        await db.listedNumbersDao.membership('+573001234567'),
        'negra',
      );
    });
  });
}
