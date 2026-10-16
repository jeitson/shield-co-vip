# Spec · 04 Dataset y sincronización — Requerimientos

> Dataset de hashes distribuido + **delta sync versionado** real, su backend
> (Supabase fase 3: `phone_hashes`, `dataset_version`, `v1-sync`, `v1-pepper`,
> pepper en Vault) y el **pepper** en el keystore del dispositivo.
>
> Fuente de arquitectura: [`03-datos-y-sincronizacion`](../../../03-architecture/03-datos-y-sincronizacion.md) §03.3/§03.4,
> [`02-seguridad`](../../../03-architecture/02-seguridad-y-criptografia.md) §02.2/§02.6,
> [`05-backend-api-metricas`](../../../03-architecture/05-backend-api-metricas.md) §05.2 (DA-05, DA-06, DA-08, DA-14).
> Esquema: [`06-database/schema/00-esquema-completo.md`](../../../06-database/schema/00-esquema-completo.md).
> Depende de: `03-persistencia-local` (DAO `PhoneHashesDao`, `core/secure`).

Esta spec hace **reales** el contador de la lista local (RF-SHIELD-06) y la
sincronización (RF-SHIELD-07, estados sincronizando/error) del Dashboard.

---

## 1. Introducción

El prototipo fingía la lista local con un número fijo (`14.892`) que crecía con
`Math.random`, y la sync con un `setTimeout`. Producción exige el mecanismo real
(`03-datos` §03.3/§03.4, `02-seguridad` §02.6):

- Un **dataset de hashes** (`phone_hashes`) en el servidor; al dispositivo solo
  llega el **hash** (HMAC-SHA256 con pepper), nunca el número (RN-01).
- **Delta sync versionado por secuencia** (`GET /v1/sync?since=N`): altas + bajas
  (soft delete) + `current_version` + `pepper_version` + `checksum`.
- **Verificación de integridad** del payload (checksum) antes de aplicar.
- El **pepper** se entrega al dispositivo autenticado (`GET /v1/pepper`), se
  guarda en keystore y nunca toca la base.
- Sincronización **manual, oportunista y en background** (`03-datos` §03.4).

### Decisión de alcance (B1, confirmada con el usuario)

`v1-sync` y `v1-pepper` exigen **sesión válida de Supabase Auth** (JWT del login).
El subsistema completo de **`devices`** (registro, exclusividad por número DA-03,
revocación DA-04) se difiere a la spec `devices` (B2) — a hacerse lo antes
posible. Cuando exista, `v1-sync`/`v1-pepper` solo añaden la verificación de
"dispositivo activo"; el resto no cambia. Esto es sync **real autenticado**, no
un mock.

---

## 2. Requerimientos — Backend (Supabase)

### R1 · Esquema del dataset
**Historia:** como plataforma, almaceno las firmas de números peligrosos y un
contador global para distribuirlas por delta.

Criterios (EARS):
1. EL SISTEMA DEBERÁ crear `public.phone_hashes` (hash, numero_legible solo
   server-side, categoria, nivel, added_at_version, removed_at_version,
   pepper_version) según `03-datos` §03.1.
2. EL SISTEMA DEBERÁ crear `public.dataset_version` **singleton** (current_version,
   pepper_version).
3. EL SISTEMA DEBERÁ aplicar RLS que **impida** al cliente leer `phone_hashes`
   directo (solo service role / Edge); el cliente obtiene datos **solo** vía
   `v1-sync` (`03-datos` §03.2).
4. CUANDO se da de alta o baja una firma, EL SISTEMA DEBERÁ reflejarlo con
   `added_at_version` / `removed_at_version` e incrementar `current_version`
   (soft delete, idempotencia del delta).

### R2 · Pepper en Vault y entrega
**Historia:** como sistema criptográfico, custodio el pepper en Vault y lo entrego
solo a clientes autenticados.

Criterios (EARS):
1. EL SISTEMA DEBERÁ almacenar el pepper en **Supabase Vault** (secreto), nunca en
   `app_params` ni en el repo (`02-seguridad` §02.2, §05.5).
2. CUANDO un cliente con **sesión válida** pide `GET /v1/pepper`, EL SISTEMA DEBERÁ
   devolver `{ pepper, pepper_version }` sobre TLS.
3. SI no hay sesión válida, EL SISTEMA DEBERÁ responder 401 sin entregar nada.
4. EL SISTEMA DEBERÁ calcular los `phone_hashes` del seed como
   `HMAC-SHA256(pepper, numero_normalizado_E164)` con el mismo pepper que entrega
   (para que el matching del dispositivo coincida).

### R3 · Edge Function `v1-sync` (delta real)
**Historia:** como dispositivo, descargo solo los cambios desde mi última versión.

Criterios (EARS):
1. CUANDO el cliente autenticado pide `GET /v1/sync?since=N`, EL SISTEMA DEBERÁ
   responder `{ current_version, pepper_version, altas:{phone_hashes:[...]},
   bajas:{phone_hashes:[...]}, checksum, full }` (`05.2`).
2. CUANDO `since=0` o el gap supera `sync_full_gap` (de `app_params`) o cambió
   `pepper_version`, EL SISTEMA DEBERÁ responder un **full** (`full: true`,
   dataset activo completo).
3. EL SISTEMA DEBERÁ incluir un `checksum` (sha256) del payload para la
   verificación de integridad del cliente (`02-seguridad` §02.6).
4. SI no hay sesión válida, EL SISTEMA DEBERÁ responder 401.
5. EL SISTEMA DEBERÁ ser **idempotente**: el mismo `since` devuelve el mismo
   resultado.

### R4 · Seed de datos de prueba
**Historia:** como equipo, necesito datos realistas para validar el flujo
extremo a extremo.

Criterios (EARS):
1. EL SISTEMA DEBERÁ sembrar **~300** números colombianos **inventados**
   (`+573XXXXXXXXX`, RN-04) distribuidos entre las categorías de RN-07 con sus
   niveles, calculando su `hash` con el pepper real.
2. EL SISTEMA DEBERÁ dejar `dataset_version.current_version` consistente con el
   seed.

---

## 3. Requerimientos — App (features/sync)

### R5 · Pepper en keystore
**Historia:** como app, obtengo y custodio el pepper para hashear números
entrantes localmente.

Criterios (EARS):
1. CUANDO hay sesión y aún no hay pepper local, EL SISTEMA DEBERÁ obtenerlo de
   `v1-pepper` y guardarlo en **keystore** (`core/secure`), nunca en la base.
2. EL SISTEMA DEBERÁ guardar también `pepper_version` para detectar rotación.
3. CUANDO se cierra sesión / revoca, EL SISTEMA DEBERÁ poder borrar el pepper.

### R6 · Delta sync en el cliente
**Historia:** como app, aplico altas/bajas a la base local verificando integridad.

Criterios (EARS):
1. CUANDO se dispara una sync, EL SISTEMA DEBERÁ pedir `v1-sync?since=last_synced_version`.
2. CUANDO llega el payload, EL SISTEMA DEBERÁ **verificar el checksum** antes de
   aplicar; si falla, DEBERÁ **rechazar** sin tocar la base y marcar error de
   integridad (`02-seguridad` §02.6).
3. CUANDO el checksum es válido, EL SISTEMA DEBERÁ aplicar altas (`upsertAll`) y
   bajas (`markRemoved`) vía `PhoneHashesDao` y actualizar `last_synced_version`.
4. CUANDO la respuesta es `full`, EL SISTEMA DEBERÁ `clearAll` y reconstruir;
   si cambió `pepper_version`, DEBERÁ reemplazar el pepper del keystore.
5. SI no hay red o el servidor falla, EL SISTEMA DEBERÁ exponer un **estado de
   error** reutilizable por la UI (no romper la app) y permitir reintento.
6. EL SISTEMA DEBERÁ persistir `last_synced_version` y `last_synced_at` localmente.

### R7 · Disparadores de sync (manual + automático/oportunista)
**Historia:** como usuario, mi lista se mantiene fresca sin esfuerzo, y puedo
forzar una actualización.

Criterios (EARS):
1. EL SISTEMA DEBERÁ permitir **sync manual** (botón del Dashboard, RF-SHIELD-07)
   exponiendo estados cargando/éxito/error.
2. EL SISTEMA DEBERÁ ejecutar sync **oportunista** al abrir la app (si hay sesión)
   y al **recuperar conectividad** (`03-datos` §03.4).
3. EL SISTEMA DEBERÁ ejecutar sync **en background** periódico (diario) vía
   WorkManager en Android (`03-datos` §03.4). *(iOS diferido.)*
4. EL SISTEMA NO DEBERÁ ejecutar syncs solapadas (debe serializar / de-duplicar
   una sync en curso).

### R8 · Estado de sync observable (para el Dashboard)
**Historia:** como UI, observo el estado de la sync y el conteo de la lista local.

Criterios (EARS):
1. EL SISTEMA DEBERÁ exponer el **conteo de firmas activas** de forma reactiva
   (de `PhoneHashesDao.watchCountActive`) para el contador (RF-SHIELD-06).
2. EL SISTEMA DEBERÁ exponer un estado de sync con: inactivo, sincronizando,
   éxito (con `last_synced_at`), error (con causa) — EST-SHIELD-04/05.
3. EL SISTEMA DEBERÁ formatear `last_synced_at` en es-CO para la UI.

---

## 4. Fuera de alcance (esta spec)

- Subsistema **`devices`** completo: registro, exclusividad por número (DA-03),
  refresh con revocación (DA-04). → spec `devices` (B2), inmediatamente después.
- `allowlist_hashes`, `domain_hashes`, `content_rules`: estructura prevista pero
  matching diferido (`03-datos` §03.3).
- **Reportes** (`v1-report`) y **métricas** (`v1-metrics`): fases posteriores.
- **Certificate pinning** (DA-14): hardening transversal sobre `ApiClient`.
- El **matching** del número entrante contra el `Set` (usa el pepper): spec
  `05-motor-bloqueo`.
