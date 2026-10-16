# Spec · 03 Persistencia local cifrada — Diseño

> Diseño técnico de `core/db` (drift + SQLite cifrado) y `core/secure` (DEK en
> keystore) en la app Flutter (`04-app`). Alineado a Clean Architecture por
> features [DA-13], Riverpod y la arquitectura de seguridad §02.3 / §04.4.

---

## 1. Panorama

```
core/
├── secure/
│   ├── secure_keys.dart          # claves y wrappers de keystore (DEK, pepper, tokens)
│   └── local_crypto_keys.dart    # genera/lee la DEK de 256 bits (base64)
└── db/
    ├── app_database.dart         # @DriftDatabase: tablas, schemaVersion, migraciones
    ├── app_database.g.dart       # generado por drift_dev (build_runner)
    ├── tables/
    │   ├── shield_config_table.dart   # ConfigEscudo (3 capas) — fila única
    │   └── phone_hashes_table.dart    # dataset local de hashes
    ├── daos/
    │   ├── shield_config_dao.dart
    │   └── phone_hashes_dao.dart
    └── db_providers.dart         # DI: DEK → NativeDatabase cifrado → AppDatabase → DAOs
```

Regla de dependencia: las features (`data`) dependen de los DAOs; `presentation`
nunca toca drift directamente. El dominio permanece Dart puro.

---

## 2. Cifrado: enfoque elegido

La arquitectura exige **SQLCipher / AES-256** (DA-07, §02.3). A partir de drift
2.32 el camino soportado es **SQLite3 Multiple Ciphers (sqlite3mc)**, que
implementa la API C de SQLite e incluye el esquema de cifrado de SQLCipher. Se
configura vía *build hooks* del paquete `sqlite3`:

```yaml
# pubspec.yaml (raíz de la app)
hooks:
  user_defines:
    sqlite3:
      source: sqlite3mc
```

Apertura de la base con clave (DEK) y verificación de que la variante cifrada
está activa:

```dart
NativeDatabase.createInBackground(
  file,
  setup: (raw) {
    // Falla explícito si no es la variante cifrada (nunca abrir en claro).
    assert(_hasCipher(raw), 'SQLite sin soporte de cifrado (sqlite3mc)');
    raw.execute("PRAGMA cipher = 'sqlcipher';"); // modo compatible SQLCipher
    raw.execute("PRAGMA key = '${_escape(dekBase64)}';");
  },
);

bool _hasCipher(Database db) => db.select('PRAGMA cipher;').isNotEmpty;
```

> **Nota de compatibilidad:** si el toolchain de `sqlite3mc` por hooks no resuelve
> en el entorno de build, el fallback soportado es `sqlcipher_flutter_libs` +
> `package:sqlite3` 2.x con `PRAGMA key`. El contrato de `core/db` (DAOs y
> providers) **no cambia** entre ambos; solo cambia cómo se enlaza el binario
> nativo. La verificación `PRAGMA cipher` sigue aplicando. Se elige en la tarea
> de implementación según lo que resuelva limpio con Flutter 3.47 / Dart 3.13.

### DEK — generación y custodia (`core/secure`)

- 256 bits aleatorios de un CSPRNG (`Random.secure()`), codificados en base64 para
  usarlos como passphrase de `PRAGMA key`.
- Persistida en `flutter_secure_storage` bajo una clave dedicada
  (`local_db_dek_v1`), con `AndroidOptions(encryptedSharedPreferences: true)`
  (respaldo Keystore), igual que el `AuthSessionStore` ya existente (DA-14).
- Independiente de la contraseña: nunca se deriva de credenciales. Un reset de
  clave no la toca.
- API:

```dart
class LocalCryptoKeys {
  Future<String> getOrCreateDek();   // crea 256b la primera vez; luego reusa
  Future<void> deleteDek();          // revocación/borrado de material (R2.5)
}
```

> El mismo `core/secure` albergará luego el **pepper** (spec `04-dataset-sync`) y
> ya custodia los **tokens** (en `AuthSessionStore`). Aquí solo se añade la DEK.

---

## 3. Esquema v1 (drift)

### Tabla `shield_config` — fila única (ConfigEscudo)

Espeja `ConfigEscudo` de `00-fundamentos` (3 booleanos, defecto `true`). Fila
única con `id` fijo = 1 (patrón singleton), para persistir y observar la config.

| Columna | Tipo | Defecto | Notas |
|---------|------|:---:|-------|
| `id` | int (pk) | 1 | singleton |
| `extorsion` | bool | true | capa crítica |
| `callcenter` | bool | true | capa spam |
| `ley` | bool | true | capa Ley 2300 |
| `updated_at` | datetime | now | auditoría local |

Semilla: en la migración v1 (o al primer acceso del DAO) se inserta la fila 1 con
las 3 capas en `true` (RN-SHIELD-04). El DAO expone `watchConfig()` (stream) y
`setLayer(layer, enabled)`.

### Tabla `phone_hashes` — dataset local

Subconjunto distribuible del esquema de servidor (`03-datos` §03.1/§03.3): al
dispositivo solo llega el **hash**, nunca el número legible. `added_at_version` /
`removed_at_version` habilitan el delta sync (spec siguiente).

| Columna | Tipo | Notas |
|---------|------|-------|
| `hash` | text (pk) | HMAC-SHA256(pepper, número) — opaco para el cliente |
| `categoria` | text | catálogo RN-07 |
| `nivel` | text | ALTO/MEDIO/BAJO |
| `added_at_version` | int | versión del dataset en que entró |
| `removed_at_version` | int? | null = activo (soft delete para el delta) |
| `pepper_version` | int | para detectar rotación de pepper (full resync) |

Índices: por `categoria`/`nivel` para conteos segmentados; `removed_at_version`
nulo para "activos". El DAO expone `countActive()`, `watchCountActive()`,
`activeHashes()` (para el `Set` en memoria), y operaciones de upsert/soft-delete
en lote (las usará `04-dataset-sync`).

---

## 4. Inyección de dependencias (`db_providers.dart`)

```dart
final localCryptoKeysProvider = Provider<LocalCryptoKeys>(
  (ref) => LocalCryptoKeys(ref.watch(secureStorageProvider)),
);

// Abre la base cifrada (async): DEK → NativeDatabase → AppDatabase.
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final dek = await ref.watch(localCryptoKeysProvider).getOrCreateDek();
  final db = AppDatabase(await openEncrypted(dek));
  ref.onDispose(db.close);
  return db;
});

final shieldConfigDaoProvider = FutureProvider<ShieldConfigDao>(...);
final phoneHashesDaoProvider  = FutureProvider<PhoneHashesDao>(...);
```

Reutiliza el `secureStorageProvider` ya definido en `auth_providers.dart` (se
mueve/expone desde `core/secure` para no acoplar a auth; se mantiene el mismo
provider para no duplicar instancias de `FlutterSecureStorage`).

> **Refactor menor:** `secureStorageProvider` pasa de `features/auth/presentation`
> a `core/secure/secure_providers.dart`; `auth_providers.dart` lo re-exporta o
> importa desde ahí. Cambio no funcional, mantiene auth intacto.

---

## 5. Arranque

- La base se abre **perezosamente** vía `appDatabaseProvider` (FutureProvider) la
  primera vez que una feature la pide; no se bloquea el `main`.
- `bootstrap` no cambia su firma; opcionalmente se puede "precalentar"
  `appDatabaseProvider` tras construir el `ProviderScope`, pero no es obligatorio.
- La apertura usa `createInBackground` (isolate) para no congelar la UI (R5.1).

---

## 6. Dependencias nuevas (`pubspec.yaml`)

| Paquete | Ámbito | Para qué |
|---------|--------|----------|
| `drift` | dep | ORM tipado + migraciones |
| `sqlite3` | dep | motor nativo (con hook `sqlite3mc` para cifrado) |
| `path` / `path_provider` | dep | ubicar el archivo `.db` en el sandbox de la app |
| `drift_dev` | dev | generación de código |
| `build_runner` | dev | runner de codegen |

(Si se usa el fallback: `sqlcipher_flutter_libs` en lugar del hook `sqlite3mc`.)

---

## 7. Pruebas

- **DEK**: `getOrCreateDek` genera 256 bits la primera vez y reusa después;
  `deleteDek` borra. Con un `FlutterSecureStorage` en memoria/mock.
- **Esquema/DAO** (con `NativeDatabase.memory()` sin cifrado para el test lógico):
  - `shield_config` nace con las 3 capas en `true` (R3.4) y `setLayer` persiste y
    emite por el stream.
  - `phone_hashes`: upsert + soft-delete, `countActive()` ignora los `removed`,
    `activeHashes()` devuelve el `Set` esperado.
- **Cifrado (integración, dispositivo/emulador)**: `PRAGMA cipher` no vacío; abrir
  con DEK incorrecta falla. Se documenta como verificación manual si no corre en
  CI sin dispositivo.
- `flutter analyze` + `dart format` limpios tras el codegen.
