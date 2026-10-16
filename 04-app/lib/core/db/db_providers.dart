import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/db/daos/events_dao.dart';
import 'package:shield_app/core/db/daos/listed_numbers_dao.dart';
import 'package:shield_app/core/db/daos/phone_hashes_dao.dart';
import 'package:shield_app/core/db/daos/shield_config_dao.dart';
import 'package:shield_app/core/db/encrypted_database.dart';
import 'package:shield_app/core/secure/local_crypto_keys.dart';
import 'package:shield_app/core/secure/secure_providers.dart';

/// Custodia de la DEK de la base local (keystore).
final localCryptoKeysProvider = Provider<LocalCryptoKeys>(
  (ref) => LocalCryptoKeys(ref.watch(secureStorageProvider)),
);

/// Base local cifrada, abierta de forma perezosa y asíncrona.
///
/// Resuelve la DEK del keystore → abre `NativeDatabase` cifrado → construye el
/// [AppDatabase]. Las features consumen este `FutureProvider` desde su capa de
/// datos; nunca se abre la base en el hilo de UI del arranque (R5).
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final dek = await ref.watch(localCryptoKeysProvider).getOrCreateDek();
  final db = AppDatabase(openEncryptedDatabase(dek));
  ref.onDispose(db.close);
  return db;
});

/// DAO de la configuración del escudo (depende de la base ya abierta).
final shieldConfigDaoProvider = FutureProvider<ShieldConfigDao>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.shieldConfigDao;
});

/// DAO del dataset local de hashes.
final phoneHashesDaoProvider = FutureProvider<PhoneHashesDao>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.phoneHashesDao;
});

/// DAO del historial de eventos interceptados (spec 03, feature `events`).
final eventsDaoProvider = FutureProvider<EventsDao>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.eventsDao;
});

/// DAO de las listas locales confianza/negra (spec 03, feature `lists`).
final listedNumbersDaoProvider = FutureProvider<ListedNumbersDao>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.listedNumbersDao;
});
