# core/db

Persistencia local **cifrada** (drift + SQLite3MultipleCiphers / SQLCipher).
Implementada en la spec [`03-persistencia-local`](../../../../.kiro/specs/03-persistencia-local/).

Responsabilidad ([DA-07], `03-architecture/04-app-flutter.md` §04.4, `02-seguridad` §02.3):

- `drift` + cifrado AES-256 (estilo SQLCipher) con la **DEK** del keystore
  (`core/secure/LocalCryptoKeys`). La base nunca se abre en claro: `openEncryptedDatabase`
  verifica `PRAGMA cipher` y aborta si la variante cifrada no está activa.
- Migraciones versionadas (`schemaVersion`, `MigrationStrategy`).

## Contenido

- `app_database.dart` — `@DriftDatabase` (esquema v1 + migraciones + semilla).
- `encrypted_database.dart` — apertura cifrada con la DEK (`PRAGMA key`).
- `tables/` — `shield_config` (ConfigEscudo, singleton) y `phone_hashes` (dataset local).
- `daos/` — `ShieldConfigDao` (watch/read/setLayer) y `PhoneHashesDao`
  (countActive/watchCountActive/activeHashes/upsert/markRemoved/clearAll).
- `db_providers.dart` — DI: DEK → `NativeDatabase` cifrado → `AppDatabase` → DAOs.

## Esquema

v1 crea `shield_config` (3 capas, defecto `true`, RN-SHIELD-04) y `phone_hashes`
(hash HMAC + categoría + nivel + versiones de dataset/pepper para el delta sync).
Las tablas de listas, eventos y métricas se añadirán por migración incremental
cuando llegue su feature.

Para el volumen esperado (miles de hashes) la lista cabe en memoria como `Set`
(`PhoneHashesDao.activeHashes()`) para matching O(1); la SQLite es la persistencia.
