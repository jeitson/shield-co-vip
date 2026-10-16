# Spec · 03 Persistencia local cifrada — Plan de implementación

> Infra transversal: base local cifrada (drift + SQLite3MultipleCiphers / SQLCipher)
> + DEK en keystore. Desbloquea `04-dataset-sync`, `05-motor-bloqueo` y
> `06-escudo-dashboard`. No incluye UI.

- [x] 1. Dependencias y toolchain de cifrado
  - [x] 1.1 Añadir `drift` 2.35, `sqlite3` 3.7, `path`, `path_provider` (deps) y
    `drift_dev`, `build_runner` (dev) a `pubspec.yaml`; `flutter pub get`.
  - [x] 1.2 Configurar el cifrado: hook `sqlite3mc` en `pubspec.yaml`
    (`hooks.user_defines.sqlite3.source: sqlite3mc`). Resolvió limpio con
    Flutter 3.47/Dart 3.13 (sqlite3 3.x usa hooks nativos). Fallback documentado
    en design §2 por si un entorno de build no soporta el hook.
  - _Req: R1, DA-07, DA-14_

- [x] 2. core/secure — DEK en keystore
  - [x] 2.1 `secureStorageProvider` movido a `core/secure/secure_providers.dart`
    (+ `secureAndroidOptions`); `auth_providers.dart` ahora lo importa de ahí.
  - [x] 2.2 `LocalCryptoKeys` con `getOrCreateDek()` (256b aleatorios, base64) y
    `deleteDek()`; clave `local_db_dek_v1`, `encryptedSharedPreferences: true`.
  - [x] 2.3 `localCryptoKeysProvider` (en `db_providers.dart`).
  - _Req: R2_

- [x] 3. core/db — esquema v1 y apertura cifrada
  - [x] 3.1 Tablas drift: `shield_config` (singleton, 3 capas def. true, updatedAt)
    y `phone_hashes` (hash pk, categoria, nivel, added/removed_at_version, pepper_version).
  - [x] 3.2 `AppDatabase` (`@DriftDatabase`), `schemaVersion = 1`, `MigrationStrategy`
    (`onCreate` crea tablas + semilla de `shield_config` fila 1 con 3 capas true).
  - [x] 3.3 `openEncryptedDatabase(dek)`: `NativeDatabase.createInBackground` con
    `setup` que verifica `PRAGMA cipher` (falla explícito si no cifrado) y aplica
    `PRAGMA cipher='sqlcipher'` + `PRAGMA key`.
  - [x] 3.4 `build_runner` genera `app_database.g.dart` y los `*_dao.g.dart`.
  - _Req: R1, R3, R5_

- [x] 4. DAOs y providers
  - [x] 4.1 `ShieldConfigDao`: `watchConfig()`, `readConfig()`, `setLayer(layer,bool)`
    (asegura fila singleton).
  - [x] 4.2 `PhoneHashesDao`: `countActive()`, `watchCountActive()`, `activeHashes()`,
    `upsertAll` / `markRemoved` / `clearAll` (API lista para el sync).
  - [x] 4.3 `db_providers.dart`: `appDatabaseProvider` (FutureProvider) + providers de DAOs.
  - _Req: R4_

- [x] 5. Verificación
  - [x] 5.1 Tests: DEK (crea/reusa/borra/aleatoriedad, 4 tests); `shield_config`
    nace 3-true + `setLayer`/`watchConfig`/singleton; `phone_hashes`
    upsert/soft-delete/count/set/clear (10 tests). Suite completa: 51 tests OK.
  - [x] 5.2 `flutter analyze` + `dart format` limpios.
  - [ ] 5.3 Verificación de cifrado en dispositivo/emulador (`PRAGMA cipher` no
    vacío; apertura con DEK incorrecta falla). **Pendiente manual**: requiere
    device/emulador (no disponible en este entorno de CI). El código ya aborta
    si la variante cifrada no está activa (`_assertCipherAvailable`).
  - _Req: todos_

---

## Nota de dependencias para las specs siguientes

- `04-dataset-sync` escribirá en `phone_hashes` vía `PhoneHashesDao`
  (`upsertAll`/`markRemoved`/`clearAll`) y guardará el **pepper** en `core/secure`
  (mismo `secureStorageProvider`).
- `05-motor-bloqueo` leerá `activeHashes()` para el `Set` de matching O(1) y la
  config vía `ShieldConfigDao`.
- `06-escudo-dashboard` observará `watchConfig()` y `watchCountActive()`.
