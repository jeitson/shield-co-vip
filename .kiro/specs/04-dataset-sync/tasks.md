# Spec · 04 Dataset y sincronización — Plan de implementación

> Dataset de hashes + delta sync real + pepper. Backend (Supabase fase 3) y app
> (`features/sync`). Decisión B1: autenticado por sesión Auth; `devices` difiere
> a la spec B2. Hace reales RF-SHIELD-06 (contador) y RF-SHIELD-07 (sync).

## 1. Backend — esquema (`06-database` canónico + copia CLI)
- [x] 1.1 `0005_dataset.sql`: `dataset_version` (singleton) + `phone_hashes`
  (hash, numero_legible, categoria, nivel, added/removed_at_version, pepper_version)
  + índices (`unique(hash,pepper_version)`, added, removed); seed `app_params.sync_full_gap=500`.
- [x] 1.2 `0006_dataset_rls.sql`: RLS ON sin policies de cliente (solo Edge/service).
- [x] 1.3 Copias con timestamp en `05-backend/supabase/migrations/` (0005/0006/0007).
- _Req: R1_

## 2. Backend — pepper (Vault) y seed
- [x] 2.1 `0007_pepper_and_seed.sql`: crea pepper en **Vault** (`vault.create_secret`,
  32 bytes aleatorios) + RPC `get_dataset_pepper()` security definer (solo service_role).
- [x] 2.2 Seed en SQL (pgcrypto `hmac`): 300 números CO inventados por categoría/nivel
  (40% extorsión ALTO / 20% phishing ALTO-MEDIO / 25% callcenter MEDIO / 15% ley BAJO),
  `hash = encode(hmac(E164, pepper, 'sha256'),'hex')`, `added_at_version=1`,
  `dataset_version=(1,1)`. Idempotente.
- _Req: R2, R4_

## 3. Backend — Edge Functions
- [x] 3.1 `v1-pepper/index.ts`: valida JWT → RPC `get_dataset_pepper` → `{pepper, pepper_version}` (401 si no).
- [x] 3.2 `v1-sync/index.ts`: valida JWT → delta `{current_version, pepper_version,
  altas, bajas, checksum, full}`; full si since<=0/gap/pepper distinto; checksum sha256
  canónico; idempotente.
- _Req: R2, R3_

## 4. Despliegue backend (DESPLEGADO al proyecto real, aprobado por el usuario)
- [x] 4.1 `supabase db push` de 0005/0006/0007 vía pooler IPv4. Verificado por REST:
  `dataset_version=(current:1,pepper:1)`, `phone_hashes` = **300 filas**, pepper en Vault,
  RLS bloquea lectura anónima (anon → `[]`).
- [x] 4.2 `supabase functions deploy v1-pepper v1-sync` → desplegadas OK.
- [x] 4.3 Verificado: sin token → **401** en ambas; con token de sesión real →
  `v1-pepper` devuelve pepper(32B)+version; `v1-sync?since=0` → `full`, **300 altas**,
  checksum. Usuario QA creado y **borrado** tras la prueba.
- _Req: R1–R4_

## 5. App — pepper en keystore
- [x] 5.1 `core/secure/pepper_store.dart` (pepper + pepper_version en secure storage).
- [x] 5.2 `PepperRepository` + `PepperRepositoryImpl` (keystore-first, fallback v1-pepper).
- _Req: R5_

## 6. App — red autenticada
- [x] 6.1 `SupabaseAuthInterceptor` (Bearer JWT de la sesión + apikey) en `core/network`.
- [x] 6.2 Dio/ApiClient dedicado de sync con versión + auth + error mapper (`sync_providers`).
- _Req: R6_

## 7. App — delta sync (dominio + datos)
- [x] 7.1 Entidades `SyncDelta`/`HashSignature`, `SyncState`; DTO `SyncDeltaDto`;
  `SyncChecksum` (recomputa sha256 canónico idéntico al servidor). `IntegrityFailure`.
- [x] 7.2 `SyncRemoteDataSource` (GET v1-sync/v1-pepper) + `SyncMetadataStore` (last_version/at).
- [x] 7.3 `DatasetRepositoryImpl.syncNow`: verifica checksum → aplica full/delta vía
  `PhoneHashesDao` → persiste last_synced; serializa (de-dup). `countActive`/`watchCount`.
- [x] 7.4 Caso de uso `SyncDataset`.
- _Req: R6, R8_

## 8. App — estado + disparadores
- [x] 8.1 `sync_providers.dart`: `datasetCountProvider` (stream), `pepperRepositoryProvider`,
  `datasetRepositoryProvider`; `sync_controller.dart` (AsyncNotifier<SyncState>).
- [x] 8.2 `sync_triggers.dart`: disparo al autenticarse + al recuperar red
  (`connectivity_plus`), activado desde `app.dart`.
- [x] 8.3 Background diario con `workmanager` (`sync_background.dart`), registrado en
  `bootstrap` (Android). iOS diferido.
- _Req: R7, R8_

## 9. Verificación
- [x] 9.1 Tests: checksum (determinista/verify/rechazo), full/delta aplican, de-dup,
  IntegrityFailure no aplica, PepperRepository keystore-first, watchCount. Suite: 63 OK.
- [x] 9.2 `flutter analyze` + `dart format` limpios.
- [x] 9.3 Prueba e2e contra el backend real: `v1-sync?since=0` devolvió 300 altas y un
  checksum que el cliente Dart **recomputa idéntico** (test `checksum_crosscheck_test.dart`
  sobre el payload real → verifica cross-lenguaje TS↔Dart). Falta solo correr el sync
  dentro de la app en dispositivo (se cubre al integrar el Dashboard, spec D).
- _Req: todos_

---

## Nota para specs siguientes
- `05-motor-bloqueo` usará el **pepper** (`PepperRepository`) para `HMAC(entrante)`
  y `PhoneHashesDao.activeHashes()` para el `Set` de matching.
- `06-escudo-dashboard` consumirá `datasetCountProvider`, `syncControllerProvider`.
- La spec `devices` (B2) añadirá a `v1-sync`/`v1-pepper` el chequeo de dispositivo activo.
