import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/secure/local_crypto_keys.dart';
import 'package:shield_app/core/secure/pepper_store.dart';
import 'package:shield_app/features/device/data/device_id_store.dart';
import 'package:shield_app/features/device/data/session_wiper.dart';

/// Secure storage en memoria.
class _MemStorage implements FlutterSecureStorage {
  final Map<String, String> m = {};
  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => m[key];
  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => value == null ? m.remove(key) : m[key] = value;
  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => m.remove(key);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  group('DeviceIdStore', () {
    test('crea un UUID la primera vez y lo reutiliza', () async {
      final store = DeviceIdStore(_MemStorage());
      final a = await store.getOrCreate();
      final b = await store.getOrCreate();
      expect(a, isNotEmpty);
      expect(a, b);
      expect(await store.read(), a);
    });

    test('dos instalaciones distintas generan ids distintos', () async {
      final a = await DeviceIdStore(_MemStorage()).getOrCreate();
      final b = await DeviceIdStore(_MemStorage()).getOrCreate();
      expect(a, isNot(b));
    });
  });

  group('SessionWiper', () {
    test('borra pepper, DEK y dataset local (DA-04)', () async {
      final storage = _MemStorage();
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      // Sembrar material: pepper, DEK y una firma en el dataset.
      final pepperStore = PepperStore(storage);
      await pepperStore.write('pepper-x', 1);
      final keys = LocalCryptoKeys(storage);
      await keys.getOrCreateDek();
      await db.phoneHashesDao.upsertAll([
        PhoneHashesTableCompanion.insert(
          hash: 'h1',
          categoria: 'Extorsión / amenaza',
          nivel: 'ALTO',
          addedAtVersion: 1,
          pepperVersion: 1,
          removedAtVersion: const Value(null),
        ),
      ]);
      expect(await db.phoneHashesDao.countActive(), 1);

      final wiper = SessionWiper(
        pepperStore: pepperStore,
        cryptoKeys: keys,
        phoneHashesDao: db.phoneHashesDao,
      );
      await wiper.wipe();

      expect(await pepperStore.readPepper(), isNull);
      // La DEK se borró (storage ya no la tiene bajo su clave).
      expect(storage.m.containsKey('local_db_dek_v1'), isFalse);
      expect(await db.phoneHashesDao.countActive(), 0);
    });
  });
}
