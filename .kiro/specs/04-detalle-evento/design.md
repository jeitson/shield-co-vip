# Spec · 04 Detalle de evento — Diseño

> Diseño técnico de la ficha forense `RecordDetailScreen` (PANT-DETAIL) y de la
> feature `reports` (reporte comunitario anónimo) en `04-app`, más el backend del
> reporte (migración `reports` + Edge Function `v1-report`) en `05-backend`
> (escrito, **sin deploy**).
> Clean Architecture por features (DA-13), Riverpod, Dio autenticado
> (`x-device-id`), tokens de `core/theme`. Regla de dependencia:
> `presentation → domain ← data`.

---

## 1. Panorama

Se **expande** una pantalla existente y se crea **una feature nueva** (`reports`),
reutilizando todo lo que la spec 03 ya dejó cableado (carga por id, listas,
motor). El bloqueo local **no se reimplementa**: se invoca `classifyNumber`.

```
features/
├── events/
│   └── presentation/
│       ├── record_detail_screen.dart      # (expandir) ficha forense completa
│       ├── controllers/
│       │   └── detail_action_controller.dart   # NEW estado de las 2 acciones
│       ├── state/
│       │   └── detail_action_state.dart        # NEW idle/generating/success/error…
│       └── widgets/
│           ├── inspection_card.dart            # NEW número + badge + vector tabs
│           ├── vector_tabs.dart                # NEW Llamada/SMS
│           ├── forensic_metadata.dart          # NEW fecha/ubicación/actividad
│           ├── sms_payload_sandbox.dart        # NEW payload + enlace resaltado
│           ├── block_options_module.dart       # NEW explicación + chips + nota + botones
│           ├── category_selector.dart          # NEW chips sobre ThreatCategory
│           └── privacy_footer.dart             # NEW "Tu privacidad está protegida"
│
└── reports/                              # NEW feature reporte comunitario
    ├── domain/
    │   ├── entities/
    │   │   └── community_report.dart     # número + categoría (lo que el usuario envía)
    │   │   └── report_outcome.dart       # pendiente | yaReportado | rechazadoProtegido
    │   ├── repositories/
    │   │   └── reports_repository.dart    # contrato report(...)
    │   └── usecases/
    │       └── submit_report.dart         # valida + delega
    ├── data/
    │   ├── reports_remote_data_source.dart        # interfaz
    │   ├── reports_remote_data_source_api.dart    # REAL → v1-report (ApiClient)
    │   ├── reports_remote_data_source_fake.dart   # FAKE en memoria (dedup)
    │   └── reports_repository_impl.dart
    └── presentation/
        └── reports_providers.dart         # DI + selección real/fake por hasSupabase

core/widgets/
└── primary_button.dart                    # (mover desde auth; reutilizable)
```

Backend (`05-backend`, escrito, sin deploy):

```
supabase/
├── migrations/
│   └── 20260101000009_reports.sql         # NEW tabla reports + índices + RLS
└── functions/
    └── v1-report/
        └── index.ts                       # NEW POST /v1/report (anónimo, DA-10)
```

---

## 2. Reutilización (lo que NO se reimplementa)

- **Carga por id:** `eventByIdProvider(id)` (`events_providers.dart`) ya resuelve
  `GetEvent.getById` y mapea a `null` en error. La pantalla sigue consumiéndolo.
- **Bloqueo local + exclusividad RN-05 + motor:** `classifyNumberProvider.call(
  sender, ListKind.negra, origin: ListOrigin.evento)` ya escribe en
  `numeros_listados`, retira de confianza (RN-05) y dispara la cadena
  `negraNumbersProvider → negraHashesProvider → engineIndexProvider →
  engineProjectionProvider.project(native)`. **No se toca el motor.**
- **Estado de clasificación reactivo:** `membershipProvider.family(sender)` para
  pintar BLOQUEADO/CONFIABLE en la ficha.
- **Red autenticada:** el `ApiClient` sobre `deviceAwareDioProvider` ya añade
  `Authorization: Bearer` + `x-device-id` + `x-app-version`. `v1-report` se invoca
  como `v1-session`/`v1-sync`.
- **device_id anónimo:** `DeviceIdStore.getOrCreate()` (UUID de instalación, no
  PII). El header `x-device-id` lo pone el interceptor; el `device_id_anon` del
  cuerpo se resuelve del mismo store.
- **Catálogos:** `ThreatCategory` (RN-07), `ThreatLevel`, `ContactChannel`.
- **PrimaryButton:** se **mueve** de `features/auth/presentation/widgets/` a
  `core/widgets/` (lo usan auth y ahora el detalle). Import actualizado en auth.

---

## 3. Dominio — `reports`

### Entidades

```dart
/// Lo que el usuario decide reportar (mínimo, anónimo). El device_id anónimo lo
/// resuelve la capa de datos desde el DeviceIdStore (no es decisión de dominio).
class CommunityReport {
  final String numero;            // sender canónico E.164 (RN-04)
  final ThreatCategory categoria; // catálogo RN-07
  const CommunityReport({required this.numero, required this.categoria});
}

/// Desenlace del reporte (gobierna la UI del estado de acción).
enum ReportOutcome {
  pendiente,          // aceptado, en moderación (DA-10)
  yaReportado,        // dedup: este device ya lo reportó (idempotente, R9)
  rechazadoProtegido, // allowlist de protección (R8.3)
}
```

> `yaReportado` y `pendiente` son ambos "éxito" para el bloqueo; la diferencia es
> solo informativa. `rechazadoProtegido` **no** es error reintentar-able.

### Repositorio (contrato)

```dart
abstract interface class ReportsRepository {
  /// Envía el reporte comunitario anónimo. El bloqueo local NO es parte de este
  /// contrato (lo hace `lists`); aquí solo viaja el reporte al backend.
  Future<Result<ReportOutcome>> report(CommunityReport report);
}
```

### Caso de uso `SubmitReport`

Valida que el número no sea vacío y delega en el repositorio. El controller de la
UI es quien orquesta **bloqueo local primero, reporte después** (§6), para que el
bloqueo se conserve aunque el reporte falle (R8.2).

---

## 4. Datos — `reports` (real + fake)

### Datasource (interfaz + dos implementaciones)

```dart
abstract interface class ReportsRemoteDataSource {
  Future<Result<ReportOutcome>> report({
    required String numero,
    required ThreatCategory categoria,
  });
}
```

- **`ReportsRemoteDataSourceApi`** (REAL): usa el `ApiClient`
  (`deviceAwareDioProvider`) para `POST v1-report` con cuerpo
  `{ numero, categoria: <label estable>, device_id_anon: <uuid> }` (el
  `device_id_anon` sale de `DeviceIdStore.getOrCreate()`). Mapea la respuesta:
  - `200 { estado: "pendiente" }` → `Ok(ReportOutcome.pendiente)`
  - `200 { estado: "ya_reportado" }` → `Ok(ReportOutcome.yaReportado)`
  - `200/4xx { estado: "rechazado", motivo: "numero_protegido" }` →
    `Ok(ReportOutcome.rechazadoProtegido)`
  - red/5xx/otros → `Err(Failure)` (reintentar-able, R8.1). Usa `postRaw` para
    distinguir por cuerpo (patrón de `v1-session/refresh`).
  - **Categoría en el cuerpo:** se envía el `ThreatCategory.label` (mismo literal
    que el seed/servidor) para que el backend lo reconozca con `fromLabel`.

- **`ReportsRemoteDataSourceFake`** (FAKE): mantiene un `Set` de números ya
  reportados en memoria; primer reporte → `pendiente`, repetido → `yaReportado`.
  Permite validar toda la UI sin backend (tests / offline), igual que
  `AuthRemoteDataSourceFake`.

### Selección real/fake

En `reports_providers.dart`, mismo patrón que `authRemoteDataSourceProvider`:

```dart
final reportsRemoteDataSourceProvider = Provider<ReportsRemoteDataSource>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.hasSupabase) {
    return ReportsRemoteDataSourceApi(
      ref.watch(apiClientProvider),           // sobre deviceAwareDioProvider
      ref.watch(deviceIdStoreProvider),
    );
  }
  return ReportsRemoteDataSourceFake();
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) =>
    ReportsRepositoryImpl(ref.watch(reportsRemoteDataSourceProvider)));

final submitReportProvider = Provider<SubmitReport>((ref) =>
    SubmitReport(ref.watch(reportsRepositoryProvider)));
```

---

## 5. Backend — reporte comunitario (código, sin deploy) [DA-10]

### Migración `20260101000009_reports.sql`

Estilo de `0008_devices.sql`: tabla + índices + RLS sin escritura para el cliente.

```sql
create table if not exists public.reports (
  id             uuid primary key default gen_random_uuid(),
  hash           text not null,            -- HMAC(pepper, numeroE164), igual que phone_hashes
  numero_legible text not null,            -- infractor, SOLO moderación/auditoría
  categoria      text not null,            -- catálogo RN-07 (label)
  device_id_anon uuid not null,            -- reportante anónimo (dedup)
  pepper_version int  not null,            -- versión de pepper usada al hashear
  estado         text not null default 'pendiente'
                   check (estado in ('pendiente','promovido','rechazado')),
  created_at     timestamptz not null default now(),
  -- Dedup DA-10: un device cuenta UNA vez por número.
  unique (device_id_anon, hash, pepper_version)
);

create index if not exists idx_reports_hash on public.reports (hash, pepper_version);

alter table public.reports enable row level security;
-- Sin policy de insert/update/delete para el cliente: solo la Edge Function
-- (service role) escribe. (03-datos §03.2 [DA-11].)
```

> La **allowlist de protección** reutiliza una tabla/criterio existente de
> protección de números legítimos; si aún no existe como tabla independiente, la
> Edge Function consulta la fuente que defina la operación. En el MVP se verifica
> contra una lista de números protegidos (semilla mínima en `app_params` o tabla
> `protected_numbers`); el diseño deja el **punto de verificación** explícito y
> fácil de poblar. La **promoción por umbral** (pg_cron) queda fuera de alcance.

### Edge Function `v1-report/index.ts`

Estilo de `v1-sync`/`v1-session`: CORS, `requireActiveDevice`, lectura del pepper
por la RPC `get_dataset_pepper`, HMAC con `pgcrypto` o Web Crypto, allowlist,
upsert idempotente.

```ts
// POST /v1/report  { numero, categoria, device_id_anon }  → { estado }
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  const ctx = await requireActiveDevice(req, corsHeaders);   // Auth + device activo
  if (ctx instanceof Response) return ctx;
  const { admin, deviceId } = ctx;

  const { numero, categoria } = await req.json();
  const e164 = normalizeE164(numero);                        // +57 por defecto (RN-04)
  if (!e164) return json({ error: "numero_invalido" }, 400);

  // 1) allowlist de protección → rechazado
  if (await isProtected(admin, e164)) {
    return json({ estado: "rechazado", motivo: "numero_protegido" }, 200);
  }

  // 2) pepper vigente + HMAC (misma función que el dataset/seed)
  const { data: p } = await admin.rpc("get_dataset_pepper");
  const { pepper, pepper_version } = p[0];
  const hash = await hmacSha256Hex(e164, pepper);

  // 3) upsert idempotente (dedup por device_id_anon + hash + pepper_version)
  const { error, data } = await admin
    .from("reports")
    .upsert({
      hash, numero_legible: e164, categoria,
      device_id_anon: deviceId, pepper_version, estado: "pendiente",
    }, { onConflict: "device_id_anon,hash,pepper_version", ignoreDuplicates: true })
    .select();

  if (error) return json({ error: "report_failed" }, 500);
  const estado = (data && data.length === 0) ? "ya_reportado" : "pendiente";
  return json({ estado }, 200);
});
```

Notas:
- El `device_id_anon` del cuerpo se **ignora en favor del `x-device-id`** validado
  por `requireActiveDevice` (no se confía en el cuerpo para la identidad del
  dispositivo). Esto cierra el riesgo de spoofing y mantiene la dedup honesta.
- `categoria` se guarda como **label** del catálogo (igual que `phone_hashes`),
  validando contra el conjunto conocido; categoría desconocida → `400`.
- El HMAC usa el **mismo algoritmo** que `v1-sync`/el seed para que, al promover,
  el hash coincida con el dataset.

### Verificación local (sin remoto)

- `deno check 05-backend/supabase/functions/v1-report/index.ts` (tipado).
- `supabase functions serve v1-report` + `curl` contra local, o un test de
  Deno del normalizador/handler. **Nunca** `functions deploy`/`db push` remoto en
  esta spec (R12.3, R-DEPLOY-01).

---

## 6. Presentación — `RecordDetailScreen` + controller

### Estado de acción (`detail_action_state.dart`)

```dart
enum DetailActionKind { none, dualReport, localBlock }
enum DetailActionPhase { idle, generating, success, error }

class DetailActionState {
  final DetailActionKind kind;
  final DetailActionPhase phase;
  final ReportOutcome? outcome;   // tras éxito del reporte
  final String? errorMessage;     // tras error del reporte (reintentable)
  final bool localBlockDone;      // "Número Silenciado Localmente"
  // + copyWith
}
```

### Controller (`detail_action_controller.dart`)

`Notifier<DetailActionState>` (family por evento o parametrizado por `sender`):

- **`reportAndBlock(sender, category)`** (R5):
  1. `phase = generating`.
  2. `classifyNumber(sender, ListKind.negra)` → bloqueo local (R5.1a, R7).
  3. `submitReport(CommunityReport(sender, category))` → backend (R5.1b).
  4. éxito (`pendiente`/`yaReportado`) → `phase = success, outcome`; si
     `rechazadoProtegido` → `success` con aviso "número protegido" (R8.3, el
     bloqueo local se mantiene); si `Err` → `phase = error, errorMessage`
     conservando el bloqueo y la categoría (R8.2).
- **`blockLocal(sender)`** (R6): `classifyNumber(sender, ListKind.negra)` →
  `localBlockDone = true` ("Número Silenciado Localmente"). Sin reporte.
- **`retryReport(...)`**: reintenta solo el paso 3 (el bloqueo ya está hecho).

El **orden bloqueo→reporte** garantiza R8.2 (el usuario queda protegido aunque el
reporte falle).

### Pantalla (expandir el stub)

`eventAsync.when(loading / error→_unavailable / data)` se mantiene (R10). En
`data`, se arma la ficha con los widgets nuevos:

1. **Indicador** "Número Sospechoso · Identificado por la comunidad".
2. **`InspectionCard`**: etiqueta "Número Desconocido", icono por `type`, `sender`
   seleccionable, **badge de peligro** = `ThreatLevel` (color + `label`,
   R13.3), y **`VectorTabs`** (inicial = `type`, R1.4).
3. **`ForensicMetadata`**: fecha/hora, **ubicación** (`details?.ubicacion`), tipo
   de actividad (`threatTitle`), categoría/reputación/diagnóstico (R1.3). La
   pestaña activa cambia el encabezado del vector; el contenido forense es común.
4. **`SmsPayloadSandbox`** (solo si `hasQuarantine` y vector SMS, R2):
   `SelectableText` plano (sin `Linkify`) con el segmento del enlace **resaltado**
   (se parte el texto buscando `http`), + alerta "enlace peligroso". Enlace **no
   navegable** (R2.2).
5. **`BlockOptionsModule`** (R3–R6):
   - Dos tarjetas explicativas (bloquear en tu teléfono / ayudar a otros).
   - **`CategorySelector`**: chips sobre `ThreatCategory.values` (o un subconjunto
     curado de las categorías "reportables"), preseleccionando `event.category`
     (R3.1/3.2). Un chip activo a la vez.
   - Campo **nota** opcional (`TextField`, R4).
   - **`PrimaryButton`** "Reportar y bloquear" con `loading` durante `generating`
     y override a verde (`AppColors.success`) en `success`; etiqueta según fase
     ("Generando Prueba ZK & Inmunizando…" / "¡Bloqueado y Sincronizado!"). Si no
     hay categoría, al tocar muestra aviso y no envía (R3.3).
   - Botón secundario "Bloquear solo para mí" → "Número Silenciado Localmente"
     (R6.2). Si ya está en lista negra (`membershipProvider == negra`), refleja el
     estado.
   - Estado **error** del reporte con botón **Reintentar** (R8).
   - Estado **"ya reportado"** informado cuando `outcome == yaReportado` (R9.2).
6. **`PrivacyFooter`**: "Tu privacidad está protegida · 100% anónimo"
   (RN-DETAIL-02).

Volver (R11): `AppBar` back / back del sistema → go_router devuelve a `/calls`
(la ruta ya abre sobre el shell con `parentNavigatorKey: _rootNavigatorKey`).

### Mapeo prototipo → dominio (gaps a cubrir)

- Ubicación: el prototipo usa `details.location`; el dominio es
  `details?.ubicacion` → mapear ese campo.
- Chips de categoría del prototipo (strings) → `ThreatCategory` (RN-07).
- Botón dual del prototipo (3 estados de color) → `PrimaryButton` + overrides.

---

## 7. Accesibilidad (R13)

Severidad con **texto redundante** (`ThreatLevel.label`) junto al color; objetivos
táctiles ≥ 48 dp; `Semantics` (button/selected) en pestañas, chips y botones;
`SelectableText` del sandbox con semántica de solo lectura; solo tokens de
`core/theme`.

---

## 8. Pruebas

- **Dominio `reports`:** `SubmitReport` valida número vacío; mapeo de desenlaces.
- **Datasource fake:** primer reporte → `pendiente`, repetido → `yaReportado`
  (idempotencia local, R9).
- **Datasource api (unit con Dio mock/adapter):** cuerpo correcto
  (`numero/categoria/device_id_anon`), mapeo de `pendiente`/`ya_reportado`/
  `rechazado:numero_protegido`/error.
- **Controller (`detail_action_controller`):** `reportAndBlock` bloquea **antes**
  de reportar; si el reporte falla, `localBlockDone`/categoría se conservan y el
  estado es `error` reintentable; `retryReport` no re-bloquea; `blockLocal` no
  reporta; `rechazadoProtegido` no es error.
- **Widget `RecordDetailScreen`** (`ProviderScope(overrides)`): vector inicial por
  `type`; sandbox solo en SMS y **no navegable**; chips desde `ThreatCategory` con
  preselección; "Reportar y bloquear" sin categoría pide elegir; estados
  generating→success; error con reintentar; "evento no disponible" cuando el id no
  resuelve.
- **Backend (Deno, local):** test del normalizador E.164 y del handler con un
  cliente admin falso (allowlist rechaza; dedup devuelve `ya_reportado`). `deno
  check` del archivo. **Sin** deploy.
- **Suite + `flutter analyze`** verdes antes de cerrar.

---

## 9. Dependencias nuevas

Ninguna externa en Flutter (`dio`, `flutter_riverpod`, `uuid` ya están). En el
backend, `pgcrypto` ya está habilitado (migración 0007). La Edge Function usa
`jsr:@supabase/supabase-js@2` y Web Crypto (ya en uso por `v1-sync`).
