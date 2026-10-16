# Spec · 03 Registro de eventos — Plan de implementación

> Opción A (confirmada): feature `events` completa + feature `lists` mínima
> (habilita RN-05 y re-cablea el motor). El **origen de datos real**
> (puente nativo→Dart) queda fuera de alcance; se entrega el contrato de
> inserción `EventsRepository.record()`.
> Orden: datos/persistencia → dominio → motor → presentación → verificación.
> Dispositivo de prueba de referencia: Moto g04s, Android 14.

- [x] 1. Persistencia: tablas, DAOs y migración v1→v2 (R1)
  - [x] 1.1 Tabla `InterceptedEventsTable` (`eventos`) en `core/db/tables/` con los campos de `InterceptedEvent` (id PK, sender, type, level, timestamp, threatTitle, category, reputationTag, diagnosis, quarantinedContent nullable, detailsJson nullable).
  - [x] 1.2 Tabla `ListedNumbersTable` (`numeros_listados`) con `numero` PK (unicidad = RN-05 por esquema), `lista`, `origen`, `updatedAt`.
  - [x] 1.3 `EventsDao`: `watchAll()` (orden `timestamp` desc), `getById(id)`, `insertOne(companion)`, `countBetween(dayStart,dayEnd)`, `countByLevel(level)`, `watchPage(limit,offset)`, `clearAll()`.
  - [x] 1.4 `ListedNumbersDao`: `watchMembership(numero)`/`membership(numero)`, `classify(numero, lista?, origen)` en **transacción** (exclusividad RN-05: upsert por `numero`), `numbersIn`/`watchByLista(lista)` → `Set<String>`.
  - [x] 1.5 Registrar ambas tablas y DAOs en `AppDatabase`; subir `schemaVersion` a 2; añadir `onUpgrade` que cree solo las tablas nuevas (no destructivo con `shield_config`/`phone_hashes`). Codegen regenerado.
  - [x] 1.6 Providers `eventsDaoProvider` y `listedNumbersDaoProvider` en `core/db/db_providers.dart` (patrón de `phoneHashesDaoProvider`).
  - _Req: R1_ · Verificado: `app_database_test.dart` (grupos `eventos`, `numeros_listados`, coexistencia v2) + `migration_v1_v2_test.dart` (onUpgrade real, no destructivo). 128 tests, analyze limpio.

- [x] 2. Dominio `lists` (mínima) y exclusividad RN-05 (R7)
  - [x] 2.1 Entidad `ListedNumber` + enums `ListKind {confianza,negra}` (con `storageValue`/`fromStorage`), `ListOrigin {manual,evento,simulador}`.
  - [x] 2.2 Contrato `ListsRepository` (`watchMembership`, `classify`, `watchConfianza`, `watchNegra`).
  - [x] 2.3 `ListsRepositoryImpl` sobre `ListedNumbersDao`. Normalización E.164 (RN-04) en `canonical_number.dart` (reutiliza `ColombianPhone`; conserva códigos cortos SMS tal cual).
  - [x] 2.4 Casos de uso `ClassifyNumber` (set/unset con exclusividad, normaliza) y `WatchListMembership`.
  - [x] 2.5 `lists_providers.dart`: `listsRepositoryProvider`, `classifyNumberProvider` (acción), `membershipProvider.family(numero)`, `confianzaNumbersProvider`/`negraNumbersProvider` (fuente del motor).
  - _Req: R7 (RN-05), RN-04_ · Verificado: `test/features/lists/classify_number_test.dart` (normalización + exclusividad + desmarcar + inválido). Analyze limpio.

- [x] 3. Dominio `events` (R2, R5, R9, R10)
  - [x] 3.1 Entidad `InterceptedEvent` (reutiliza `ContactChannel`, `ThreatLevel`, `ThreatCategory`) + `EventDetails` + getters `isSicEligible` (category == ley2300, RN-CALLS-02) y `hasQuarantine` (SMS con contenido).
  - [x] 3.2 `EventFilter` + enums `EventTypeFilter` / `EventLevelFilter` (chips mutuamente excluyentes, `matches()`).
  - [x] 3.3 Contrato `EventsRepository` (`watchAll`, `getById`, `record`) y `EventsRepositoryImpl` + `EventMapper` (row ↔ entidad, enums + `detailsJson`).
  - [x] 3.4 Casos de uso `WatchEvents`, `GetEvent`, `RecordEvent` (valida id/sender).
  - [x] 3.5 `events_providers.dart`: DI (repo), `eventsStreamProvider`, `telemetryProvider` (hoy/críticas/tiempoAhorrado con `kAvgSecondsSavedPerEvent=45`), `totalEventsCountProvider` (chip "Todos N"), `visibleEventsProvider` (búsqueda normalizada acentos-insensible + filtro AND + `EmptyReason` inicial/filtro). Controller de filtro + `events_view_state`.
  - _Req: R2, R3, R4, R5, R9, R10_ · Verificado: `test/features/events/events_domain_test.dart` (SIC, cuarentena, búsqueda, AND, vacío inicial/filtro, telemetría). Analyze limpio, 142 tests.

- [x] 4. Re-cableado del motor con listas locales (R7.6)
  - [x] 4.1 Proveedores puente `confianzaHashesProvider` / `negraHashesProvider` en `lists/presentation/list_hashes_providers.dart` que hashean los números (reutilizan `HmacHasher` + pepper de `pepperStoreProvider`, igual que el dataset) y degradan a vacío si no hay pepper.
  - [x] 4.2 En `engine_providers.dart`, `engineIndexProvider.whitelistLocal`/`blacklistLocal` se alimentan desde esos providers (reemplazan `const {}`); al ser streams reactivos, una reclasificación recomputa el índice y `engineProjectionProvider` reproyecta al nativo.
  - [x] 4.3 Test de integración `test/features/lists/list_hashes_integration_test.dart`: hashea con pepper, degrada sin pepper, vacío→vacío.
  - _Req: R7.6_ · Verificado: analyze limpio, 145 tests (motor existente intacto).

- [x] 5. Presentación — `CallsScreen` (R2–R11)
  - [x] 5.1 `events_filter_controller` + `events_view_state` (texto de búsqueda + `EventFilter`).
  - [x] 5.2 `TelemetryTiles` (3 micro-tarjetas reactivas, altura fija).
  - [x] 5.3 `FilterChips`: "Todos (N)" con total sin filtrar (RN-CALLS-05), Llamadas/SMS/Alto/Medio/Bajo; un chip activo a la vez.
  - [x] 5.4 `EventCard`: glow/icono/badge por `ThreatLevel` + label textual redundante (R11.3), badges CONFIABLE/BLOQUEADO reactivos (`membershipProvider`), barra de acciones.
  - [x] 5.5 `QuarantineSandbox`: solo SMS con contenido; `SelectableText` plano no navegable (enlaces no clicables, R8).
  - [x] 5.6 `EventsStatePanel` (welcome/noResults/error) + `EventsLoadingSkeleton`: vacío inicial, vacío por filtro, carga y error con reintentar (R6).
  - [x] 5.7 Acciones: clasificar confianza/negra con toast efímero 2500ms (R7); "Exportar SIC" visible solo si `isSicEligible` → enganche `onExportSic` (R9); "Ver detalles" → `goNamed(eventDetailName, {'id'})` (R10).
  - [x] 5.8 Placeholder de `calls_screen.dart` reemplazado por la pantalla real, fiel a `CallsScreen.tsx`, solo tokens de `core/theme`, táctiles ≥48dp, `Semantics`.
  - _Req: R2, R3, R4, R5, R6, R7, R8, R9, R10, R11_

- [x] 6. Detalle: carga por id (enganche para spec 04) (R10)
  - [x] 6.1 `RecordDetailScreen` resuelve el evento vía `eventByIdProvider`/`GetEvent` (ruta `/calls/:id`), con estado "evento no disponible" (RF-DETAIL-11). Vista mínima de datos; el detalle forense completo es la spec 04.
  - _Req: R10_

- [x] 7. Paginación / carga incremental (R12)
  - [x] 7.1 Paginación en presentación **sobre la lista ya filtrada** (coherente con búsqueda/filtro, R12.2): `visiblePageSizeProvider` (ventana de `kEventsPageSize=50`, se reinicia al cambiar criterio) + `pagedVisibleEventsProvider` (recorta + `hasMore`). `CallsScreen` auto-carga bajo scroll (`ScrollController`) y ofrece botón "Ver más".
  - _Req: R12_ · Verificado: 4 tests de provider (recorte, loadMore, reset por búsqueda, sin exceso) + widget test (solo primera página materializada).

- [ ] 8. Verificación
  - [x] 8.1 Tests de DAO/DB: migración v1→v2 no destructiva; `watchAll` orden desc; `countBetween`/`countByLevel`; `classify` respeta RN-05 (nunca en ambas listas; desmarca).
  - [x] 8.2 Tests de dominio: `ClassifyNumber` (E.164 + exclusividad); `isSicEligible` por categoría; búsqueda normalizada; `visibleEventsProvider` (AND búsqueda+filtro, vacío inicial vs. filtro); telemetría.
  - [x] 8.3 Widget tests de `CallsScreen` con overrides: búsqueda+chip (AND), estados vacíos, badge por membresía, SIC condicional, sandbox solo SMS, navegación a detalle con id.
  - [x] 8.4 `flutter analyze` sin issues; suite completa verde (158 tests).
  - [x] 8.5 Prueba en dispositivo (Moto g04s, Android 14): **validada por el usuario**. APK release del flavor dev instalado y autónomo; login real OK tras el fix del permiso `INTERNET`; siembra de eventos (Avanzados → Desarrollo) y el timeline del Registro funcionando en pantalla. (La interceptación real de llamada/SMS en vivo requiere conceder el rol de call screening y recibir un contacto bloqueado; el camino de persistencia quedó verificado vía el mismo contrato `RecordEvent`.)
  - _Req: todos_

---

## 9. Productor real de eventos (puente nativo→Dart + siembra) — cierra el pendiente de la spec

- [x] 9.1 **Cola nativa persistente** `EventQueueStore` (archivo en `filesDir`): el `CallScreeningService` y el `SmsReceiver` **encolan** cada interceptación (BLOCK) con `{rawNumber, channel, layer, body?, timestampMs}`. Necesario porque esos componentes corren sin FlutterEngine vivo (no se puede empujar en caliente).
- [x] 9.2 `PrecedenceMatcher.evaluate` extendido para devolver también la **capa** responsable del bloqueo (`MatchResult`), sin romper `decide`. Call screening y SMS receiver encolan con esa capa.
- [x] 9.3 Canal `drainEvents` en `BlockingEngineChannel` (nativo→Dart, pull): devuelve y vacía la cola.
- [x] 9.4 Lado Dart: `NativeEventQueue.drain()` + `drainInterceptedEventsProvider` que **rehidrata** cada evento (categoría por hash del `EngineIndex`, o por capa del nativo) con `ThreatPresentation` (nivel/título/reputación/diagnóstico) y persiste vía `recordEventProvider`/`RecordEvent`. `interceptedEventsDrainerProvider` drena al montar el shell y al volver a `resumed` (observador de ciclo de vida).
- [x] 9.5 Siembra de desarrollo (`devEventSeederProvider`) en Avanzados (solo flavor dev): inserta 3 eventos de ejemplo por el mismo contrato `RecordEvent`. **No** se usa el Simulador de negocio para esto (spec 07 es sandbox puro, RN-SIM-01).
- [x] 9.6 Verificación: analyze limpio; tests `threat_presentation_test` + `intercepted_events_bridge_test` (rehidratación por dataset y por capa, cuarentena SMS, cola vacía). APK dev compila (Kotlin nuevo) e instala en el Moto g04s.
  - _Req: spec 03 §3 (contrato de inserción) + pendiente "productor real de eventos"_

---

## Notas de integración con otras specs

- **Origen de eventos (fuera de alcance):** el puente nativo (CallScreeningService
  / receiver SMS → Dart) y el Simulador (spec 07) insertarán eventos reales vía
  `RecordEvent`/`EventsRepository.record()`. Esta spec deja ese contrato listo.
- **Detalle (spec 04):** consumirá `GetEvent` y las acciones de `lists`
  (reportar+bloquear / bloquear local heredan RN-05).
- **Listas y configuración (spec 05):** ampliará la feature `lists` con la UI de
  administración, importación y allowlist global; aquí queda el núcleo (tabla +
  exclusividad + motor).
- **Canales de denuncia (spec 06):** implementará el flujo real de evidencia SIC
  detrás del enganche `onExportSic`.
