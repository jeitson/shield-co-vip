# Spec · 04 Detalle de evento — Plan de implementación

> Opción A (confirmada): **todo implementado de forma real**. Ficha forense
> completa + bloqueo local (reutiliza `lists`/motor) + feature `reports` real
> (datasource real contra `v1-report` **y** fake, selección por
> `AppConfig.hasSupabase`) + backend del reporte **escrito y verificable en local**
> (migración `reports` + Edge Function `v1-report`). El **deploy al remoto queda
> fuera de alcance** y requiere confirmación explícita del usuario (R-DEPLOY-01).
> Orden: reutilizables → dominio/datos `reports` → backend (código) → presentación
> → verificación.
> Dispositivo de prueba de referencia: Moto g04s, Android 14.

- [x] 1. Preparación y reutilizables
  - [x] 1.1 Mover `PrimaryButton` de `features/auth/presentation/widgets/primary_button.dart` a `core/widgets/primary_button.dart` (usando el move con actualización de imports); actualizar los imports en `auth`. Verificar que login/registro siguen compilando.
  - [x] 1.2 Confirmar los puntos de reutilización ya existentes (no reimplementar): `eventByIdProvider`, `classifyNumberProvider`, `membershipProvider`, `apiClientProvider`/`deviceAwareDioProvider`, `deviceIdStoreProvider`, `ThreatCategory`/`ThreatLevel`/`ContactChannel`.
  - _Req: R13.2 (PrimaryButton), R1/R6/R7 (reutilización)_

- [x] 2. Dominio `reports`
  - [x] 2.1 Entidad `CommunityReport { numero, categoria: ThreatCategory }` y enum `ReportOutcome { pendiente, yaReportado, rechazadoProtegido }` en `features/reports/domain/entities/`.
  - [x] 2.2 Contrato `ReportsRepository.report(CommunityReport) → Future<Result<ReportOutcome>>` en `features/reports/domain/repositories/`.
  - [x] 2.3 Caso de uso `SubmitReport` (valida número no vacío; delega).
  - _Req: R5, R9_

- [x] 3. Datos `reports` (real + fake)
  - [x] 3.1 Interfaz `ReportsRemoteDataSource.report({numero, categoria})`.
  - [x] 3.2 `ReportsRemoteDataSourceApi`: `POST v1-report` vía `ApiClient.postRaw` con cuerpo `{ numero, categoria: label, device_id_anon: <DeviceIdStore.getOrCreate()> }`; mapea `pendiente`/`ya_reportado`/`rechazado:numero_protegido`/error→`Err`.
  - [x] 3.3 `ReportsRemoteDataSourceFake`: `Set` en memoria; primer reporte `pendiente`, repetido `yaReportado` (idempotencia local).
  - [x] 3.4 `ReportsRepositoryImpl` sobre el datasource.
  - [x] 3.5 `reports_providers.dart`: `reportsRemoteDataSourceProvider` (real vs fake por `AppConfig.hasSupabase`, patrón de `authRemoteDataSourceProvider`), `reportsRepositoryProvider`, `submitReportProvider`.
  - _Req: R5, R8, R9, R12 (contrato cliente)_ · Verificar: analyze + tests de 8.1/8.2.

- [x] 4. Backend del reporte comunitario (código, SIN deploy) [DA-10]
  - [x] 4.1 Migración `05-backend/supabase/migrations/20260101000009_reports.sql`: tabla `reports` (id, hash, numero_legible, categoria, device_id_anon, pepper_version, estado check pendiente/promovido/rechazado, created_at), `unique(device_id_anon,hash,pepper_version)` (dedup DA-10), índice `idx_reports_hash`, RLS habilitada **sin** policy de escritura para el cliente (solo service role). Estilo de `0008_devices.sql`.
  - [x] 4.2 Punto de verificación de **allowlist de protección**: definir cómo se consultan los números protegidos (tabla `protected_numbers` mínima o criterio en `app_params`); dejar una semilla mínima y el helper `isProtected(admin, e164)` explícito.
  - [x] 4.3 Edge Function `05-backend/supabase/functions/v1-report/index.ts`: CORS; `requireActiveDevice` (Auth + `x-device-id` activo); normalizar E.164 (RN-04, +57 por defecto); `isProtected` → `{estado:"rechazado",motivo:"numero_protegido"}`; leer pepper por RPC `get_dataset_pepper`; HMAC-SHA256 hex (mismo algoritmo que `v1-sync`/seed); `upsert` idempotente con `onConflict` → `pendiente`/`ya_reportado`; validar `categoria` contra el catálogo (desconocida → 400). **Ignora** el `device_id_anon` del cuerpo en favor del `x-device-id` validado.
  - [x] 4.4 Verificación **local**: comentario de `v1-health` actualizado. `deno check` **no ejecutado** (deno no instalado en el entorno); la función sigue el patrón exacto de `v1-pepper`/`v1-sync` (ya desplegadas). **NO** se ejecutó `supabase db push` ni `functions deploy` (R12.3, R-DEPLOY-01).
  - _Req: R12_ · Verificado parcialmente: ver pendiente de `deno check` + deploy.

- [x] 5. Estado y controller de acciones del detalle
  - [x] 5.1 `detail_action_state.dart`: `DetailActionKind {none,dualReport,localBlock}`, `DetailActionPhase {idle,generating,success,error}`, `DetailActionState { kind, phase, outcome?, errorMessage?, localBlockDone }` + `copyWith`.
  - [x] 5.2 `detail_action_controller.dart` (`Notifier`, parametrizado por `sender`): `reportAndBlock(sender, category)` = **bloqueo local primero** (`classifyNumber` negra) → `submitReport`; conserva bloqueo/categoría ante error (R8.2); `rechazadoProtegido` no es error (R8.3). `blockLocal(sender)` = solo `classifyNumber` negra → `localBlockDone`. `retryReport(...)` = solo re-envía el reporte (no re-bloquea).
  - _Req: R5, R6, R7, R8, R9_

- [x] 6. Widgets de la ficha forense
  - [x] 6.1 `InspectionCard`: etiqueta "Número Desconocido", icono por `type`, `sender` seleccionable, badge de peligro `ThreatLevel` (color + `label`, R13.3), + `VectorTabs`.
  - [x] 6.2 `VectorTabs` (Llamada/SMS, pestaña inicial = `type`, R1.4, `Semantics`).
  - [x] 6.3 `ForensicMetadata`: fecha/hora, ubicación (`details?.ubicacion`), tipo de actividad (`threatTitle`), categoría/reputación/diagnóstico (R1.3).
  - [x] 6.4 `SmsPayloadSandbox` (solo `hasQuarantine` + vector SMS): `SelectableText` plano con el enlace **resaltado** y **no navegable** (sin `Linkify`), + alerta "enlace peligroso" (R2).
  - [x] 6.5 `CategorySelector`: chips sobre `ThreatCategory` (subconjunto reportable), preselecciona `event.category`, un chip activo a la vez (R3).
  - [x] 6.6 `BlockOptionsModule`: dos tarjetas explicativas + `CategorySelector` + campo nota opcional + `PrimaryButton` "Reportar y bloquear" (loading en generating, verde en success, textos por fase; exige categoría R3.3) + botón "Bloquear solo para mí" (→ "Número Silenciado Localmente", refleja `membershipProvider`) + estado error con **Reintentar** (R8) + aviso "ya reportado" (R9.2) + aviso "número protegido" (R8.3).
  - [x] 6.7 `PrivacyFooter`: "Tu privacidad está protegida · 100% anónimo" (RN-DETAIL-02).
  - _Req: R1, R2, R3, R4, R5, R6, R8, R9, R13_

- [x] 7. Ensamblar `RecordDetailScreen`
  - [x] 7.1 Expandir el stub: conservar `eventAsync.when(loading / error→_unavailable / data)` (R10); en `data` componer indicador + `InspectionCard` + `ForensicMetadata` + `SmsPayloadSandbox` + `BlockOptionsModule` + `PrivacyFooter`, todo con tokens de `core/theme` y táctiles ≥48dp (R13). Volver = back de go_router a `/calls` (R11).
  - [x] 7.2 Cablear el `detailActionControllerProvider(sender)` y `membershipProvider(sender)`.
  - _Req: R1–R13_

- [x] 8. Verificación
  - [x] 8.1 Tests de dominio/datos `reports`: `SubmitReport` (número vacío); fake (idempotencia `pendiente`→`yaReportado`); api con Dio mock (cuerpo correcto + mapeo de desenlaces + error).
  - [x] 8.2 Tests del `detail_action_controller`: orden bloqueo→reporte; error del reporte conserva bloqueo/categoría y es reintentable; `retryReport` no re-bloquea; `blockLocal` no reporta; `rechazadoProtegido` no es error.
  - [x] 8.3 Widget tests de `RecordDetailScreen` (overrides): vector inicial por `type`; sandbox solo SMS y no navegable; chips desde `ThreatCategory` con preselección; reportar sin categoría pide elegir; generating→success; error con reintentar; "evento no disponible".
  - [x] 8.4 Backend (Deno, local): `deno` instalado (2.9.7 vía Homebrew). `deno check supabase/functions/v1-report/index.ts` **limpio** (tipa contra los tipos reales de supabase-js). `deno test` de los helpers puros (`index_test.ts`): 7/7 verdes, incluido un **vector conocido de HMAC-SHA256** que confirma que `hmacSha256Hex` coincide con `encode(hmac(...,'sha256'),'hex')` de pgcrypto (el hash del reporte coincidirá con el dataset). **Sin** deploy.
  - [x] 8.5 `flutter analyze` sin issues; suite completa verde (**180 tests**, +22 sobre la spec 03).
  - [x] 8.6 Prueba en dispositivo (Moto g04s): APK release dev contra el backend real, **validado por el usuario** ("funciona perfecto"): detalle forense, "Bloquear solo para mí", "Reportar y bloquear" (y también desde las tarjetas del listado), botón de regreso, y "ya reportado" persistente. Backend verificado e2e por curl.
  - _Req: todos_

---

## 9. Pendiente que esta spec deja listo para el deploy (acción separada)

> **No ejecutar sin confirmación explícita (R-DEPLOY-01).** Cuando el usuario lo
> apruebe, el deploy del reporte comunitario consiste en:
> - `supabase db push` de la migración `20260101000009_reports.sql`.
> - `supabase functions deploy v1-report`.
> - Verificar por REST/`curl` autenticado que `POST /v1/report` responde
>   `pendiente`/`ya_reportado`/`rechazado` y que la dedup funciona.
> - Activar el camino real en la app (ya automático por `AppConfig.hasSupabase`).

**ESTADO: desplegado y verificado con aprobación del usuario.** Migración `0009`
aplicada (`supabase db push`) y `v1-report` desplegada (`supabase functions deploy`);
verificado e2e por curl (pendiente/ya_reportado/rechazado/400 + GET reportado). App
reinstalada en el Moto g04s.

---

## 10. Extras añadidos tras la spec (a pedido del usuario)

- [x] 10.1 **Acción "Reportar y bloquear" en las tarjetas del listado** (`EventCard`):
  reemplaza el botón "Lista Negra". Usa el mismo `detailActionControllerProvider`
  (bloqueo local + reporte), con la **categoría tomada del propio evento** (RN-07,
  sin diálogo en la tarjeta). Estados "Reportando…"/"Bloqueado" + SnackBar del
  desenlace. Test `event_card_report_test.dart`.
- [x] 10.2 **Botón de regreso** en el `AppBar` del detalle (`context.pop()` con
  fallback a `/calls`).
- [x] 10.3 **R9 "ya reportado" con el servidor como fuente de verdad.** `v1-report`
  responde `GET ?numero=` → `{reportado, protegido}`. App: `wasReportedByMe`
  (datasource real GET + fake), usecase `WasReportedByMe`, `reportedStatusProvider`;
  el detalle siembra el estado al abrir (`seedAlreadyReported`) e invalida el cache
  tras reportar. `deno check` limpio; función desplegada y verificada e2e; 183 tests.

---

## Notas de integración con otras specs

- **Registro (spec 03):** ya entrega `GetEvent`, la ruta `/calls/:id`, el stub que
  esta spec expande y las acciones de `lists` reutilizadas aquí.
- **Listas y configuración (spec 05):** ampliará la UI de administración de listas;
  esta spec solo consume `classifyNumber`/exclusividad RN-05 ya existentes.
- **Canales de denuncia (spec 06):** implementará la evidencia SIC y, eventualmente,
  la reversibilidad/acuse del reporte comunitario; esta spec deja el reporte en
  `pendiente` y el contrato listo.
- **Operación backend:** la **promoción** de reportes a blacklist global por umbral
  (pg_cron) y las métricas quedan fuera; el reporte entra en `pendiente`.
