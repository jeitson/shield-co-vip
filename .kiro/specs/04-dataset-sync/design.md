# Spec · 04 Dataset y sincronización — Diseño

> Diseño técnico del dataset de hashes, su delta sync real y el pepper. Dos
> mitades: **backend** (Supabase fase 3) y **app** (`features/sync` + `core/secure`).
> Alineado a `03-datos` §03.3/§03.4, `02-seguridad` §02.2/§02.6, `05.2`.

---

## 1. Backend (Supabase)

### 1.1 Migraciones (`06-database/migrations`, canónicas)

Siguiendo la convención existente (idempotente, `comment on`, RLS explícita):

- **`0005_dataset.sql`**
  - `public.dataset_version` singleton (`id = 1`, `current_version int`,
    `pepper_version int`).
  - `public.phone_hashes` (`id bigint identity pk`, `hash text`,
    `numero_legible text` *solo server-side*, `categoria text`, `nivel text`,
    `added_at_version int`, `removed_at_version int null`, `pepper_version int`).
  - Índices: `unique(hash, pepper_version)`; `idx` por `added_at_version` y
    `removed_at_version` (consultas del delta).
  - `app_params` seed: `sync_full_gap` (p. ej. `500`).
- **`0006_dataset_rls.sql`**
  - RLS ON en ambas tablas, **sin policies para el cliente** → nadie lee directo
    por REST (solo service role / Edge). (`03-datos` §03.2.)

> El pepper **no** es una tabla: va en **Vault** (`vault.create_secret`). El seed
> de `phone_hashes` se calcula con ese pepper (ver 1.3).

### 1.2 Edge Functions (`05-backend/supabase/functions`)

Patrón ya fijado por `v1-health` (Deno). Dos funciones nuevas:

- **`v1-pepper/`** — `GET`. Verifica el JWT de Supabase Auth (header
  `Authorization: Bearer`). Si es válido, lee el pepper de Vault y responde
  `{ pepper, pepper_version }`. Si no, `401`. Usa el `service_role` internamente
  para leer Vault; nunca expone el service key al cliente.
- **`v1-sync/`** — `GET ?since=N`. Verifica JWT. Lee `dataset_version` y calcula
  el delta:
  - `altas`: filas con `added_at_version > since AND removed_at_version IS NULL`.
  - `bajas`: `hash` de filas con `removed_at_version > since`.
  - `full` cuando `since <= 0`, `since` muy por detrás (`current - since > sync_full_gap`),
    o `pepper_version` del server distinto (el cliente lo manda en query opcional).
  - `checksum`: `sha256` del cuerpo canónico (altas+bajas+versiones) para integridad.
  - Respuesta: `{ current_version, pepper_version, altas:{phone_hashes}, bajas:{phone_hashes}, checksum, full }`.

Autenticación en las Edge Functions: se valida el JWT con la clave del proyecto
(el runtime de Supabase ya expone el usuario si se pasa el `Authorization`); se
rechaza con 401 si falta o es inválido. **[B1]** No se verifica aún
"dispositivo activo" (eso lo añade la spec `devices`).

### 1.3 Seed de ~300 números (`0007_seed_phone_hashes.sql` + script)

- Números colombianos **inventados** `+573XXXXXXXXX` (RN-04), únicos.
- Distribución (RN-07): ~40% extorsión (ALTO), ~20% phishing/vishing (ALTO/MEDIO),
  ~25% call center (MEDIO), ~15% Ley 2300 (BAJO).
- El `hash = HMAC-SHA256(pepper, numeroE164)` debe calcularse **con el pepper real**
  de Vault. Como el SQL no conoce el pepper, el seed se hace con un **script**
  (`05-backend/scripts/seed_dataset.ts`, Deno) que: lee el pepper de Vault,
  calcula los hashes, inserta en `phone_hashes` con `added_at_version = 1`,
  `pepper_version` vigente, y fija `dataset_version = (current: 1, pepper_version)`.
- Alternativa de respaldo: una función SQL `v1_hmac(pepper, numero)` con `pgcrypto`
  (`hmac(numero, pepper, 'sha256')`) para generar el seed desde SQL si se inyecta
  el pepper por variable de sesión. Se elige en implementación lo que resulte más
  simple y reproducible; el resultado (hashes correctos) es el mismo.

> **Consistencia crítica:** el algoritmo de hash del servidor y el del dispositivo
> deben ser idénticos (HMAC-SHA256, mismo pepper, mismo número E.164) o el
> matching nunca coincide. Se fija HMAC-SHA256 sobre la cadena E.164 UTF-8.

---

## 2. App — `features/sync` + `core/secure`

```
features/sync/
├── domain/
│   ├── entities/
│   │   ├── sync_delta.dart        # altas/bajas/versiones/checksum/full
│   │   └── sync_state.dart        # idle | syncing | success(at) | failure(cause)
│   ├── repositories/
│   │   ├── dataset_repository.dart   # countActive(), watchCount(), syncNow()
│   │   └── pepper_repository.dart    # getOrFetchPepper(), clear()
│   └── usecases/
│       └── sync_dataset.dart
├── data/
│   ├── dtos/sync_delta_dto.dart
│   ├── datasources/
│   │   ├── sync_remote_data_source.dart       # v1-sync / v1-pepper vía ApiClient
│   │   └── sync_metadata_store.dart           # last_synced_version/at (secure/prefs)
│   └── repositories/
│       ├── dataset_repository_impl.dart
│       └── pepper_repository_impl.dart
└── presentation/
    ├── sync_providers.dart        # DI + estado observable + disparadores
    └── sync_controller.dart       # AsyncNotifier del sync manual
core/secure/
└── pepper_store.dart              # pepper + pepper_version en keystore
```

### 2.1 Red: Dio con JWT de Supabase

Se reutiliza el `ApiClient`/Dio existente (interceptor de versión DA-15 + mapeo de
errores). Se añade un **`SupabaseAuthInterceptor`** que inyecta
`Authorization: Bearer <access_token>` leyendo la sesión activa
(`Supabase.instance.client.auth.currentSession`) y el `apikey` (anon). Así el
sync pasa por el mismo pipeline de errores (incluye 426 upgrade_required) y queda
autenticado de verdad. El `baseUrl` ya es `…/functions/v1` (`versionedApiBaseUrl`).

> No se usa `functions.invoke` del SDK para no saltarse el `AppVersionInterceptor`
> ni el `DioErrorMapper`; el contrato DA-15 exige `app_version` en cada request.

### 2.2 Pepper (`core/secure/pepper_store.dart` + `PepperRepository`)

- `PepperStore`: guarda `pepper` y `pepper_version` en `flutter_secure_storage`
  (keystore), claves `dataset_pepper_v1` / `dataset_pepper_version_v1`. Nunca en
  la base (`02-seguridad` §02.2).
- `PepperRepository.getOrFetchPepper()`: si hay pepper en keystore, lo devuelve;
  si no, llama `v1-pepper`, lo guarda y lo devuelve. `clear()` para logout/revocación.

### 2.3 Delta sync (`DatasetRepositoryImpl.syncNow`)

1. Lee `last_synced_version` (0 si nunca). Asegura pepper (`getOrFetchPepper`).
2. `GET v1-sync?since=last&pepper_version=local`.
3. **Verifica checksum** recomputando sha256 del payload; si no cuadra →
   `Err(IntegrityFailure)`, no toca la base (`02-seguridad` §02.6).
4. Si `full`: `PhoneHashesDao.clearAll()` + `upsertAll(altas)`. Si cambió
   `pepper_version`: refrescar pepper del keystore.
   Si delta: `upsertAll(altas)` + `markRemoved(bajas, current_version)`.
5. Persistir `last_synced_version = current_version` y `last_synced_at = now`.
6. Serializa: un `Completer`/flag evita syncs solapadas (R7.4).

Mapea a `Result`; errores de red/servidor → `SyncState.failure` reutilizable por
la UI (R6.5). Nunca lanza a la UI.

### 2.4 Estado observable (`sync_providers.dart`)

- `datasetCountProvider` = `StreamProvider<int>` desde `PhoneHashesDao.watchCountActive`
  (RF-SHIELD-06). Reactivo: al aplicar el delta, el contador se actualiza solo.
- `syncControllerProvider` = `AsyncNotifier<SyncState>`: expone
  idle/syncing/success(at)/failure y el método `sync()` para el botón manual.
- `lastSyncedAtProvider`: deriva el timestamp formateado es-CO.

### 2.5 Disparadores (R7)

- **Manual:** el Dashboard llama `syncControllerProvider.notifier.sync()`.
- **Oportunista al abrir:** un `appLifecycleSync` que dispara `sync()` tras login
  (cuando `authStatus == authenticated`) una vez por arranque.
- **Al recuperar red:** `connectivity_plus` escucha cambios; al volver online,
  dispara `sync()` (de-dup si ya hay una en curso).
- **Background diario:** `workmanager` registra una tarea periódica (~24h) que
  abre la base, obtiene sesión/pepper y corre el delta. Android MVP; iOS diferido.

### 2.6 Dependencias nuevas (`pubspec.yaml`)

| Paquete | Para qué |
|---------|----------|
| `connectivity_plus` | disparo oportunista al recuperar red (R7.2) |
| `workmanager` | sync periódico en background Android (R7.3) |
| `crypto` | sha256 del checksum (y HMAC si se hace matching aquí; el motor lo usa) |

---

## 3. Pruebas

- **Backend (manual/integración):** desplegado el esquema + functions + seed,
  `GET v1-pepper` sin token → 401, con token → pepper+version; `GET v1-sync?since=0`
  → full con ~300 altas y checksum válido; `since=current` → delta vacío.
- **App unitarias:**
  - `DatasetRepositoryImpl`: checksum inválido → no aplica y devuelve IntegrityFailure;
    full → clearAll+upsert; delta → upsert+markRemoved; actualiza last_synced.
  - De-dup de sync concurrente (R7.4).
  - `PepperRepository`: usa keystore si existe; si no, llama remoto y guarda.
  - `SyncController`: idle→syncing→success/failure.
- `flutter analyze` + `dart format` limpios.

---

## 4. Nota de seguridad (frontera ZK)

El cliente nunca ve `numero_legible` (vive solo server-side); solo recibe hashes.
El pepper viaja una vez tras login (TLS) y queda en keystore. El checksum protege
contra datasets corruptos/manipulados (`02-seguridad` §02.6). El certificate
pinning (DA-14) es hardening transversal posterior sobre el mismo `ApiClient`.
