# Spec · 03 Registro de eventos — Diseño

> Diseño técnico de la feature `events` (pantalla `CallsScreen`) y de la feature
> `lists` mínima (listas confianza/negra locales) en `04-app`.
> Clean Architecture por features (DA-13), Riverpod, drift + SQLCipher (DA-14),
> tokens de `core/theme`. Regla de dependencia: `presentation → domain ← data`.

---

## 1. Panorama

Dos features nuevas y un re-cableado del motor existente:

```
features/
├── events/                      # Registro de eventos (PANT-CALLS)
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── intercepted_event.dart   # EventoInterceptado (00-fundamentos)
│   │   │   └── event_filter.dart        # tipo + severidad del chip activo
│   │   ├── repositories/
│   │   │   └── events_repository.dart   # contrato (watch/record/getById)
│   │   └── usecases/
│   │       ├── watch_events.dart
│   │       ├── record_event.dart        # vía de inserción (motor/simulador)
│   │       └── get_event.dart
│   ├── data/
│   │   ├── mappers/
│   │   │   └── event_mapper.dart        # row ↔ entidad
│   │   └── repositories/
│   │       └── events_repository_impl.dart  # sobre EventsDao
│   └── presentation/
│       ├── events_providers.dart        # DI + derivados (filtro, telemetría)
│       ├── controllers/
│       │   └── events_filter_controller.dart
│       ├── state/
│       │   └── events_view_state.dart   # query + chip + resultado derivado
│       ├── calls_screen.dart            # reemplaza el placeholder
│       └── widgets/
│           ├── telemetry_tiles.dart
│           ├── filter_chips.dart
│           ├── event_card.dart
│           ├── quarantine_sandbox.dart
│           └── empty_states.dart
└── lists/                       # Listas locales mínimas (habilita RN-05)
    ├── domain/
    │   ├── entities/listed_number.dart  # NumeroListado (confianza|negra)
    │   ├── repositories/lists_repository.dart
    │   └── usecases/
    │       ├── classify_number.dart     # set/unset con exclusividad RN-05
    │       └── watch_list_membership.dart
    ├── data/repositories/lists_repository_impl.dart
    └── presentation/lists_providers.dart

core/db/
├── tables/
│   ├── intercepted_events_table.dart    # tabla `eventos`
│   └── listed_numbers_table.dart        # tabla `numeros_listados`
├── daos/
│   ├── events_dao.dart
│   └── listed_numbers_dao.dart
└── app_database.dart                    # schemaVersion 1 → 2 + onUpgrade
```

El motor existente (`features/engine/presentation/engine_providers.dart`) se
**re-cablea** para leer las listas locales (hoy `const {}`) desde la nueva
feature `lists`.

---

## 2. Dominio — `events`

### Entidad `InterceptedEvent`

Espeja `EventoInterceptado` de `00-fundamentos` §00.2. Inmutable, sin
dependencias de Flutter/drift. Reutiliza los enums del motor para no duplicar
catálogos.

```dart
class InterceptedEvent {
  final String id;
  final String sender;              // remitente, normalizado E.164 (RN-04)
  final ContactChannel type;        // reutiliza engine: call | sms
  final ThreatLevel level;          // reutiliza core/theme: alto|medio|bajo
  final DateTime timestamp;         // marcaTiempo (fecha real, RN-04)
  final String threatTitle;         // "Extorsión Carcelaria", etc.
  final ThreatCategory category;    // reutiliza engine (RN-07) — gobierna SIC
  final String reputationTag;       // "VoIP no registrado"
  final String diagnosis;           // por qué se interceptó
  final String? quarantinedContent; // solo SMS
  final EventDetails? details;      // metadatos forenses opcionales
  // Clasificación: NO se almacena en el evento; se deriva de `lists` por
  // `sender` (fuente única de verdad, evita desincronización — R7.5).
}
```

- **`isSicEligible`** → `category == ThreatCategory.ley2300` (R9, RN-CALLS-02).
- **`type`/`level`/`category`** reutilizan `ContactChannel`
  (`features/engine/domain/entities/incoming_contact.dart`), `ThreatLevel`
  (`core/theme/threat_level.dart`) y `ThreatCategory`
  (`features/engine/domain/entities/threat_category.dart`). Así la severidad, el
  color del glow y la capa responsable salen de un único catálogo.

> **Decisión clave (R7.5):** `isTrusted`/`isBlacklisted` **no** son columnas del
> evento. La pertenencia a listas es responsabilidad de `lists` y se consulta por
> `sender`. Esto garantiza que clasificar un número se refleje en **todos** sus
> eventos a la vez y que la exclusividad RN-05 tenga una sola fuente de verdad.

### `EventFilter`

```dart
enum EventTypeFilter { all, call, sms }
enum EventLevelFilter { all, alto, medio, bajo }
class EventFilter { final EventTypeFilter type; final EventLevelFilter level; }
```

El chip "Todos" corresponde a `(all, all)`; los chips de tipo y de nivel son
dimensiones independientes pero el prototipo los presenta como una fila única de
chips mutuamente excluyentes — en la UI un solo chip activo a la vez, modelado
como un `EventFilter` donde seleccionar un chip de tipo fija `level=all` y
viceversa (coherente con el prototipo).

### Repositorio (contrato)

```dart
abstract interface class EventsRepository {
  /// Stream reactivo del historial completo, orden fecha desc (R2).
  Stream<List<InterceptedEvent>> watchAll();

  /// Carga un evento por id para el detalle (R10).
  Future<Result<InterceptedEvent?>> getById(String id);

  /// Inserta un evento interceptado. Vía usada por el puente nativo y el
  /// Simulador (contrato de inserción — §3 de requirements, fuera de alcance
  /// el productor real).
  Future<Result<void>> record(InterceptedEvent event);
}
```

### Casos de uso

- `WatchEvents` — expone `watchAll()`.
- `GetEvent` — `getById(id)` para el detalle.
- `RecordEvent` — valida mínimamente y delega `record()`.

El **filtrado y la búsqueda** son lógica de presentación derivada (no van al
repositorio en el MVP): se calculan sobre la lista observada. La **paginación**
(R12) se implementa en la capa de datos cuando el historial crece (ver §6).

---

## 3. Dominio — `lists` (mínima, habilita RN-05)

### Entidad `ListedNumber`

```dart
enum ListKind { confianza, negra }
enum ListOrigin { manual, evento, simulador }   // RN NumeroListado.origen
class ListedNumber {
  final String numero;      // canónico E.164 (RN-04)
  final ListKind lista;
  final ListOrigin origen;
}
```

### Repositorio y exclusividad RN-05

```dart
abstract interface class ListsRepository {
  /// Membresía observada de un número: null | confianza | negra.
  Stream<ListKind?> watchMembership(String numero);

  /// Clasifica con EXCLUSIVIDAD atómica (RN-05): escribir en una lista retira
  /// de la otra en una sola transacción. `kind == null` = desmarcar.
  Future<Result<void>> classify({
    required String numero,
    required ListKind? kind,
    ListOrigin origin,
  });

  /// Snapshots para el motor (niveles 1 y 3 del PrecedenceEngine).
  Stream<Set<String>> watchConfianza();  // → whitelistLocal
  Stream<Set<String>> watchNegra();      // → blacklistLocal
}
```

La exclusividad vive en el DAO dentro de una transacción drift: `classify`
borra/mueve la fila del número y la inserta en la lista destino, de modo que
nunca coexisten (RN-05, R7.4).

### `ClassifyNumber` (caso de uso)

Normaliza el número a E.164 (reutiliza el VO `ColombianPhone` de `auth` o un
normalizador en `core`) antes de delegar, para que la deduplicación de RN-04 sea
real (`+57 300…` y `300…` son el mismo número).

---

## 4. Datos — tablas, DAOs y migración (R1)

### Tabla `eventos` (`InterceptedEventsTable`)

```dart
@DataClassName('InterceptedEventRow')
class InterceptedEventsTable extends Table {
  @override String get tableName => 'eventos';
  TextColumn get id => text()();                         // PK (uuid/ulid)
  TextColumn get sender => text()();                     // E.164 canónico
  TextColumn get type => text()();                       // 'call' | 'sms'
  TextColumn get level => text()();                      // 'ALTO'|'MEDIO'|'BAJO'
  DateTimeColumn get timestamp => dateTime()();          // orden desc + telemetría
  TextColumn get threatTitle => text()();
  TextColumn get category => text()();                   // label de ThreatCategory
  TextColumn get reputationTag => text()();
  TextColumn get diagnosis => text()();
  TextColumn get quarantinedContent => text().nullable()();
  TextColumn get detailsJson => text().nullable()();     // metadatos forenses
  @override Set<Column> get primaryKey => {id};
}
```

Índice por `timestamp` para el orden y la ventana "hoy".

### Tabla `numeros_listados` (`ListedNumbersTable`)

```dart
@DataClassName('ListedNumberRow')
class ListedNumbersTable extends Table {
  @override String get tableName => 'numeros_listados';
  TextColumn get numero => text()();          // PK canónico E.164 → unicidad RN-05
  TextColumn get lista => text()();           // 'confianza' | 'negra'
  TextColumn get origen => text()();          // 'manual'|'evento'|'simulador'
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override Set<Column> get primaryKey => {numero};
}
```

`numero` como PK **garantiza por esquema** que un número está en **una** lista a
la vez (RN-05): un upsert con `lista` distinta mueve de lista; eso complementa la
transacción del repositorio.

### DAOs

- `EventsDao`: `watchAll()` (orden `timestamp` desc), `getById(id)`,
  `insertOne(companion)`, `countToday(DateTime)`, `countByLevel('ALTO')`, y para
  R12 una variante paginada `watchPage(limit, offset)`.
- `ListedNumbersDao`: `watchMembership(numero)`, `classify(...)` en transacción,
  `watchByLista(ListKind)` → `Set<String>` para el motor.

### Migración v1 → v2

En `app_database.dart`:
- Registrar las dos tablas nuevas en `@DriftDatabase(tables: [...])`.
- `schemaVersion => 2`.
- Añadir `onUpgrade` al `MigrationStrategy`:

```dart
onUpgrade: (m, from, to) async {
  if (from < 2) {
    await m.createTable(interceptedEventsTable);
    await m.createTable(listedNumbersTable);
  }
},
```

No se tocan `shield_config` ni `phone_hashes` (R1.3: migración no destructiva).
Los tests usan `NativeDatabase.memory()` sin cifrado (el cifrado real se verifica
en dispositivo), siguiendo `test/core/db/app_database_test.dart`.

### Providers de acceso (en `core/db/db_providers.dart`)

```dart
final eventsDaoProvider = FutureProvider<EventsDao>((ref) async =>
    (await ref.watch(appDatabaseProvider.future)).eventsDao);
final listedNumbersDaoProvider = FutureProvider<ListedNumbersDao>((ref) async =>
    (await ref.watch(appDatabaseProvider.future)).listedNumbersDao);
```

Mismo patrón que `shieldConfigDaoProvider` / `phoneHashesDaoProvider`.

---

## 5. Presentación — `CallsScreen`

### Estado y derivación

- `eventsStreamProvider` (desde `WatchEvents`) → `AsyncValue<List<InterceptedEvent>>`.
  Resuelve los estados **cargando / error / data** (R6.1/6.2) de forma natural.
- `eventsFilterControllerProvider` (`Notifier<EventsViewState>`): guarda el texto
  de búsqueda y el `EventFilter`.
- `visibleEventsProvider` (derivado): aplica búsqueda (normalizando mayúsc./
  acentos) + filtro (AND) sobre la lista observada (R3/R4). Decide además el
  estado vacío:
  - lista base vacía → **vacío inicial** (R6.4);
  - lista base no vacía pero filtrada vacía → **vacío por filtro** (R6.3).
- `telemetryProvider` (derivado): `{ hoy, criticas, tiempoAhorrado }` a partir de
  la lista base (R5). Constante `kAvgSecondsSavedPerEvent = 45` documentada.
- `membershipProvider.family(sender)`: observa la clasificación de un número para
  pintar los badges CONFIABLE/BLOQUEADO reactivamente (R7.5).

### Widgets

- `TelemetryTiles` — 3 micro-tarjetas (hoy / tiempo ahorrado / críticas) desde
  `telemetryProvider`.
- `FilterChips` — "Todos (N)", Llamadas, SMS, Alto, Medio, Bajo; "Todos" muestra
  el total sin filtrar (RN-CALLS-05); un chip activo a la vez.
- `EventCard` — glow/icono/badge por `ThreatLevel` (helper), badges de
  clasificación desde `membershipProvider`, barra de acciones rápidas (Lista
  Negra / De confianza / Ver detalles / Exportar SIC condicional), y
  `QuarantineSandbox` solo si `type==sms && quarantinedContent!=null`.
- `QuarantineSandbox` — `SelectableText` sin reconocimiento de enlaces
  (`TextSpan` plano, no `Linkify`), con aviso visual de contenido neutralizado
  (R8.2: enlaces no navegables).
- `EmptyStates` — bienvenida (inicial) y "sin criterio" (filtro).

### Acciones (R7, R9, R10)

- Clasificar: `ref.read(classifyNumberProvider).call(sender, kind)`; muestra un
  `SnackBar` efímero (~2.5 s) de confirmación (RN-CALLS-06). La exclusividad y el
  re-pintado salen de `lists` + `membershipProvider` (reactivo).
- Exportar SIC: visible solo si `event.isSicEligible`; invoca el **enganche**
  `onExportSic(event)` (hoy un placeholder que navega/avisa; el flujo real es la
  spec 06).
- Ver detalles: `context.goNamed(AppRoutes.eventDetailName, pathParameters: {'id': event.id})`.

### Accesibilidad (R11)

Severidad siempre con **texto redundante** (`ThreatLevel.label`) además del color;
objetivos táctiles ≥ 48 dp; `Semantics` en chips y acciones; solo tokens de
`core/theme`.

---

## 6. Re-cableado del motor (R7.6)

En `features/engine/presentation/engine_providers.dart`, `engineIndexProvider`
hoy fija `whitelistLocal: const {}` y `blacklistLocal: const {}`. Se cambia para
observar las listas locales:

```dart
final whitelist = await ref.watch(confianzaHashesProvider.future); // de lists
final blacklist = await ref.watch(negraHashesProvider.future);
// ...
whitelistLocal: whitelist,
blacklistLocal: blacklist,
```

Las listas se guardan por **número canónico**, pero el motor opera con **hashes
HMAC** (pepper del keystore). Por tanto `lists` expone sets de números y un
proveedor puente los **hashea** con el mismo mecanismo que el dataset
(`04-dataset-sync`), produciendo `confianzaHashesProvider`/`negraHashesProvider`.
Al cambiar una clasificación, el stream dispara → `engineIndexProvider` recomputa
→ `engineProjectionProvider` reproyecta al nativo (ya existente). Así la
clasificación afecta el filtrado real sin tocar el `PrecedenceEngine`.

> Si la obtención del pepper no está disponible (p. ej. aún sin sync), el puente
> degrada a conjuntos vacíos sin romper el motor (comportamiento actual).

---

## 7. Pruebas

- **DAO/DB** (`NativeDatabase.memory`): migración v1→v2 crea `eventos` y
  `numeros_listados` sin perder datos; `watchAll` ordena desc; `countToday`/
  `countByLevel`; `classify` respeta RN-05 (nunca en ambas listas; desmarca).
- **Dominio** (`lists`): `ClassifyNumber` normaliza a E.164 y aplica exclusividad
  con un repo falso; `isSicEligible` por categoría.
- **Presentación** (`CallsScreen` con `ProviderScope(overrides)`): búsqueda +
  chip combinados (AND); vacío inicial vs. vacío por filtro; telemetría derivada;
  badge que cambia al clasificar; SIC visible solo en `ley2300`; sandbox solo en
  SMS y no navegable; navegación al detalle con el id correcto.
- **Motor**: `engineIndexProvider` refleja las listas locales (whitelist/blacklist
  pobladas) tras clasificar (test de integración de providers).

---

## 8. Dependencias nuevas

Ninguna externa obligatoria. Para `id` se puede usar un generador ULID/UUID: si
`uuid` ya está en el árbol, reutilizarlo; si no, generar un id ordenable por
tiempo con `DateTime.now().microsecondsSinceEpoch` + sufijo aleatorio (suficiente
para el MVP local). `drift` y `flutter_riverpod` ya están.
