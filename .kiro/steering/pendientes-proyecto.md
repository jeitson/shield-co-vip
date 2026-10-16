---
inclusion: always
---

# Memory Bank — Pendientes del proyecto Cifrado Cero

Registro vivo de pendientes, decisiones diferidas y trabajo fuera del alcance actual (MVP). Mantener actualizado conforme se cierren o aparezcan pendientes. La arquitectura detallada vive en `03-architecture/`.

> **Convención:** marcar `[ ]` pendiente, `[x]` hecho. Referenciar la decisión relacionada con `[DA-xx]` / `[DN-xx]` cuando aplique.

---

## 1. Plataforma iOS (fase futura)

- [ ] Implementar `BlockingEngine` para iOS con **Call Directory Extension** (lista precargada de números a bloquear/identificar). [DA-12]
- [ ] Implementar **Message Filter Extension** (IdentityLookup) para SMS de remitentes desconocidos. [DA-12]
- [ ] Diseñar el **empuje de la lista de hashes** a las extensiones iOS (límites de tamaño de Call Directory). [DA-12]
- [ ] Preparar diagrama de onboarding de permisos/extensiones iOS (equivalente al de Android en `04-app-flutter.md` §04.5). **Explícitamente pospuesto a pedido del usuario.**
- [ ] `BGTaskScheduler` para el sync en background en iOS (con sus límites). [DA-08]
- [ ] Flavor/target iOS en el proyecto Flutter.
- [ ] Comunicar en UI la **ausencia de paridad de interceptación** iOS vs Android (modo "proveedor de listas").

## 2. Autenticación y cuenta

- [x] **Flujo de login + registro** implementado en `04-app` (feature `auth`, Clean Arch + Riverpod). Spec en `.kiro/specs/01-autenticacion/`. UI fiel al design system, gate de consentimiento, estados cargando/éxito/error, sesión en secure storage, guard de auth real (arranque en login, DN-02).
- [x] **Backend real de auth (código).** `AuthRemoteDataSourceSupabase` sobre `supabase_flutter` (signUp/signIn/reset) cableado; `authRemoteDataSourceProvider` elige real vs. fake según `AppConfig.hasSupabase`. Esquema en `06-database/` (profiles + trigger `handle_new_user` + RLS + `app_params`) y proyecto Supabase en `05-backend/`. Spec `.kiro/specs/02-backend-database/`. [DN-01, DA-11]
- [x] **Recuperación de clave real** por email vía Supabase Auth (diálogo con campo de correo → `resetPasswordForEmail`). [DA-04]
- [x] **Backend desplegado y login validado.** CLI de Supabase instalada; 4 migraciones aplicadas al proyecto real vía `supabase db push --db-url`; verificado por REST (profiles+trigger, app_params seed, RLS). Login real OK (signUp + signInWithPassword). `04-app/dart_defines.json` apunta al backend real.
- [x] **Prueba visual en dispositivo real** (Motorola moto g04s, Android 14). App corriendo contra Supabase real vía `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_defines.json`. Registro valida y queda la sesión; logout disponible en Avanzados.
- [ ] **Prueba de registro desde cero pendiente de re-validar** tras los ajustes de UI (botón, mensaje verde, redirección a login a los ~2.5s). Nota: `adb` tenía binarios duplicados (SDK vs cask) que rompían `flutter devices`; se normalizó reiniciando el adb server del SDK.

### Ajustes de UI de auth aplicados en esta ronda
- **Botón primario propio `PrimaryButton`** (Material+InkWell con color pintado explícito) en login y registro: evita que el **Material You** del dispositivo inyecte un fondo magenta sobre `FilledButton`. Cyan `#00e5ff`/tinta `#00363d`; deshabilitado gris; registro con estados idle→cyan2→verde.
- **Login sin checkboxes de consentimiento** (solo registro los exige, RN-REG-03). `LoginFormState` ya no tiene flags de consentimiento.
- **Registro con desenlaces de éxito explícitos** (`RegisterSubmitState`: idle/submitting/success/pendingConfirmation/error). Confirmación de correo pendiente se muestra en **verde** (no rojo) y redirige al login a los ~2.5s; errores reales en rojo con texto blanco.
- **Logout** expuesto en Avanzados (`settings/AdvancedScreen`): confirma, hace `signOut()` en Supabase + borra secure storage, el guard vuelve a login. Se añadió `signOut()` al contrato `AuthRemoteDataSource`.
- [x] **Confirmación de email obligatoria (R7):** DECIDIDO que se **mantiene activada** (ninguna cuenta inicia sesión sin confirmar). Flujo construido y verificado (analyze + 114 tests): `ResendConfirmation` (usecase + `auth.resend` en Supabase + fake), `EmailNotConfirmedFailure` (login bloqueado con acción "Reenviar" neutra) y `EmailConfirmationPendingFailure` (alta en dos pasos, aviso verde + redirección a login). Plantilla `confirm-signup.html` + README para pegar en el panel de Supabase. Spec `.kiro/specs/01-autenticacion/` tarea 10. **Falta solo** la prueba en dispositivo real (registro → login bloqueado → reenviar).
- [x] **Edge Function `v1-health` desplegada** y respondiendo (HTTP 200 en `${SUPABASE_URL}/functions/v1/v1-health`). Confirma el patrón de API versionada y el pipeline de deploy de funciones. Requirió un access token personal (`sbp_...`) en `SUPABASE_ACCESS_TOKEN`.
- [x] **Refresh de sesión 12h** contra `devices`: **implementado, desplegado y verificado en dispositivo**. Spec `.kiro/specs/07-devices-sesion/` (tabla `devices` + RLS, Edge Function `v1-session` register/activate/refresh, endurecimiento de `v1-sync`/`v1-pepper` con `x-device-id`, `device_id` de instalación, registro post-login + diálogo de exclusividad DA-03, refresh con wipe de pepper/DEK/dataset DA-04). Backend desplegado con aprobación del usuario (migración 0008 + `v1-session`/`v1-sync`/`v1-pepper`); verificado e2e. En el Moto g04s, tras login real, `v1-session` → `{"estado":"activo"}` y `v1-sync` → 200 con el dataset. 114 tests OK, analyze limpio. [DA-04]
- [x] **Escudo/Dashboard (feature 02) implementado y renderizando en dispositivo.** Spec `.kiro/specs/06-escudo-dashboard/` sobre A (persistencia) + B (dataset/sync) + C (motor). Bug del body en blanco en el Moto g04s **resuelto**: `MetricTiles` usaba un `Row` con `CrossAxisAlignment.stretch` que dentro del `ListView` (alto no acotado) disparaba "BoxConstraints forces an infinite height" y tiraba el layout del `SliverList` (viewport en blanco); se acotó con `IntrinsicHeight`. `LayerCard` y el cuerpo del `ShieldScreen` aportan su propio `Material` (requerido por `Switch`/`InkWell`). Verificado visualmente: StatusBar 3/3, priming, hero, 3 capas con switches, métricas (300 hashes) y acceso al simulador.
- [ ] **OTP de verificación de celular** en registro (diseñado, no implementado en MVP). Definir proveedor SMS (Twilio u otro) y costo. [DA-04]
- [ ] Confirmar **política de contraseñas** (hoy solo longitud ≥ 8; `Password` VO preparado para endurecer sin cambiar contrato). Pregunta abierta de `01-autenticacion.md`.
- [ ] Confirmar **alcance geográfico** (hoy +57 fijo en `ColombianPhone`; ¿multi-país a futuro?). RN-REG-01.

## 2b. Registro de eventos interceptados (spec 03)

- [x] **Spec `03-registro-eventos` implementada (opción A).** `.kiro/specs/03-registro-eventos/` (requirements + design + tasks, bloques 1–7 hechos). Feature `events` completa (dominio `InterceptedEvent` + base local cifrada drift/SQLCipher + `CallsScreen` real: telemetría, búsqueda, chips, estados vacío/carga/error, sandbox SMS no navegable, SIC condicional, paginación) + feature `lists` mínima (tabla `numeros_listados`, exclusividad **RN-05** atómica, `ClassifyNumber` con normalización E.164, re-cableado del `engineIndexProvider` niveles 1/3 con hashes del pepper). Migración drift v1→v2 no destructiva (tablas `eventos` y `numeros_listados`). Enganche de detalle por id (`eventByIdProvider`) para la spec 04. Verificado: analyze limpio + 158 tests (DB, dominio, puente motor, widget). **Pendiente solo** la prueba en dispositivo (bloque 8.5). Fuera de alcance de esta spec: flujo SIC completo (spec 06), detalle `PANT-DETAIL` forense (spec 04), UI de administración de listas (spec 05).
- [x] **Productor real de eventos conectado (puente nativo→Dart).** El `CallScreeningService` (llamadas) y el `SmsReceiver` (SMS) **encolan** cada interceptación en una cola nativa persistente (`EventQueueStore` en `filesDir`), porque corren sin FlutterEngine vivo. Dart la **drena** vía `drainEvents` (MethodChannel), **rehidrata** el evento (categoría por hash del `EngineIndex` o por capa del nativo; nivel/título/diagnóstico vía `ThreatPresentation`) y lo persiste con `RecordEvent`. El drenado vive en `interceptedEventsDrainerProvider` (desde el `AppShell`): al montar y al volver a `resumed`. `PrecedenceMatcher.evaluate` ahora devuelve la capa responsable. Verificado: analyze + tests de rehidratación; APK dev compila e instala en el Moto g04s. **Nota:** el Simulador de negocio (spec 07) sigue siendo sandbox puro (RN-SIM-01); para sembrar eventos de prueba hay una **utilidad dev-only** en Avanzados → Desarrollo (`devEventSeederProvider`), no el simulador. [DA-12, spec 05-motor-bloqueo, spec 03]
- [x] **Spec `04-detalle-evento` implementada (opción A, todo real).** `.kiro/specs/04-detalle-evento/` (requirements + design + tasks, bloques 1–7 + 8.1/8.2/8.3/8.5 hechos). `RecordDetailScreen` pasó de stub a **ficha forense completa**: indicador "Número sospechoso", `InspectionCard` (número seleccionable + badge de peligro con texto redundante + badge de clasificación + `VectorTabs` Llamada/SMS), `ForensicMetadata` (fecha, ubicación `details.ubicacion`, actividad, categoría/reputación/diagnóstico), `SmsPayloadSandbox` (enlace resaltado **no navegable**, solo SMS), `BlockOptionsModule` (explicación 2 vías + `CategorySelector` sobre `ThreatCategory` RN-07 + nota opcional + `PrimaryButton` dual con estados idle→"Generando Prueba ZK…"→"¡Bloqueado y Sincronizado!" + "Bloquear solo para mí" → "Número silenciado localmente" + error/reintento + aviso "ya reportado"/"número protegido") y `PrivacyFooter`. Feature **`reports` real**: dominio (`CommunityReport`, `ReportOutcome`, `SubmitReport`) + datasource **real** contra `v1-report` (`ApiClient.postRaw`, device-aware) **y** fake en memoria, elegidos por `AppConfig.hasSupabase`. `DetailActionController` (family por `sender`) orquesta **bloqueo local primero, reporte después** (R8.2). Reutiliza sin reimplementar `eventByIdProvider`, `classifyNumber`/exclusividad RN-05, `membershipProvider` y la reproyección al motor. `PrimaryButton` movido a `core/widgets/`. Verificado: analyze limpio + **180 tests** (reports datos/dominio, controller, widget del detalle). Fuera de alcance: promoción por umbral (pg_cron) y métricas; SIC (spec 06); UI de listas (spec 05). [DA-10, RN-02, spec 04]
- [x] **Reporte comunitario — backend escrito (código, SIN deploy).** Migración `05-backend/supabase/migrations/20260101000009_reports.sql` (tabla `reports` con dedup `unique(device_id_anon,hash,pepper_version)`, RLS sin escritura del cliente, + tabla `protected_numbers` allowlist anti-envenenamiento con semilla) y Edge Function `05-backend/supabase/functions/v1-report/index.ts` (`requireActiveDevice`, normalización E.164, HMAC con pepper vía `get_dataset_pepper`, allowlist → `numero_protegido`, upsert idempotente → `pendiente`/`ya_reportado`). Sigue el patrón de `v1-pepper`/`v1-sync`. Comentario de `v1-health` actualizado. **No se desplegó nada al remoto** (R-DEPLOY-01). [DA-10]
- [x] **Verificación local del backend de reporte (sin deploy).** `deno` instalado (2.9.7). `deno check` de `v1-report` limpio y `deno test` de helpers 7/7 (incluye vector de HMAC que prueba la paridad con pgcrypto → el hash del reporte coincide con el dataset). Tarea 8.4 de la spec 04 cerrada.
- [x] **Reporte comunitario DESPLEGADO y verificado (con aprobación del usuario).** Migración `0009_reports` aplicada al proyecto remoto vía `supabase db push` (tablas `reports` + `protected_numbers` con semilla; dedup + RLS sin escritura del cliente). Edge Function `v1-report` desplegada (`supabase functions deploy`, solo subió `index.ts` + `_shared/device.ts`). Verificado e2e por `curl` autenticado (usuario QA confirmado + device activo vía `v1-session`): reporte nuevo → `pendiente`, repetido → `ya_reportado` (dedup), `+57123` → `rechazado/numero_protegido` (allowlist), categoría inválida → `400`. Datos de QA (usuario, device, reportes) **limpiados** tras la prueba. [DA-10, spec 04]
- [x] **R9 "ya reportado" completo (fuente de verdad en el servidor).** `v1-report` ahora responde también a `GET ?numero=` → `{reportado, protegido}` (mismo normalizado E.164 + HMAC con pepper, dedup por `x-device-id`). La app: `ReportsRemoteDataSource.wasReportedByMe` (real GET + fake), usecase `WasReportedByMe`, `reportedStatusProvider.family`; el detalle siembra el estado "ya reportado" al abrir (`seedAlreadyReported`) y se invalida tras reportar. Desplegado (solo función) y verificado e2e por curl: antes `reportado:false` → POST → `reportado:true`; protegido `protegido:true`. `deno check` limpio + 7 tests de helpers. App: analyze limpio + 183 tests; APK reinstalado en el Moto g04s. [spec 04 · R9]
- [x] **App actualizada en el Moto g04s.** APK release del flavor dev (`app-dev-release.apk`, 68.5 MB) compilado contra el backend real (`dart_defines.json`) e instalado (`com.cifradocero.shield_app.dev`); `INTERNET granted=true`; app lanzada. Como el backend real ya está desplegado, "Reportar y bloquear" usa el camino real (`v1-report`) por `AppConfig.hasSupabase`.
- [x] **Spec 04 cerrada funcionalmente.** Validada en dispositivo por el usuario ("funciona perfecto"): detalle forense, reportar+bloquear y bloquear-local, acción "Reportar y bloquear" también en las tarjetas del listado (reemplaza "Lista Negra"; categoría tomada del evento), botón de regreso en el detalle, y "ya reportado" persistente contra el servidor (R9). Fuera de alcance (otras specs / operación): promoción por umbral (pg_cron) → los reportes quedan en `pendiente`; reversibilidad/acuse de comunidad; evidencia SIC (spec 06); UI de administración de listas (spec 05).
- [ ] **Decisiones de negocio tomadas en la spec 04 (revisables):** "Prueba ZK" es texto de UI (no ZK-proof cripto en el MVP; hardening pendiente); el reporte envía solo `{numero, categoria, device_id_anon}` y la **nota adicional no se transmite** (minimización/anonimato); categoría **preseleccionada** del evento pero se exige confirmación consciente para reportar (RN-DETAIL-04). Reversibilidad del reporte y acuse de comunidad: fuera de alcance. Confirmar con negocio.
- [ ] **Decisiones de negocio tomadas en la spec 03 (revisables):** "tiempo ahorrado" = `nº eventos × 45s`; "intercepciones de hoy" = eventos del día local; "críticas" = nivel ALTO. Confirmar fórmula con negocio.
- [ ] **Retención/purga del historial** de eventos: no implementada (pregunta abierta de negocio #2). Definir cuántos eventos / por cuánto tiempo y si hay purga automática.

## 2c. Listas y configuración avanzada (spec 05) + motor Ley 2300 (spec 08)

- [x] **Spec `05-listas-configuracion` implementada (gestión de listas, opción A).** `.kiro/specs/05-listas-configuracion/` (requirements + design + tasks). `AdvancedScreen` pasó de stub a centro de control: **gestión real de listas de confianza/negra** (`ListManagerCard` + `NumberChip`, `ListAdminController`) reutilizando toda la plomería `lists` de la spec 03 — alta con normalización RN-04, deduplicación por forma canónica, **exclusividad RN-05 también en el alta manual**, baja, contadores, estado vacío y error de entrada (el alta manual exige móvil CO `+57…` o código corto numérico; rechaza `+++`/`abc`). Acceso al **Simulador**, logout y sembrador dev conservados; sin "Modo Marco Móvil". **Tarjeta Ley 2300 de solo lectura** (R11) con las 3 franjas de RN-08 desde fuente única `core/legal/ley2300_hours.dart` + nota de bloqueo offline. No se tocó `core/db`/`lists`/motor/backend. Verificado: analyze limpio + **196 tests** (+13). **Pendiente solo** la prueba en dispositivo (tarea 5.2).
- [x] **Preguntas de negocio de la spec 05 resueltas (DN-05..DN-09).** PN#1 franjas **fijas** no editables (solo capa on/off) [DN-05]; PN#2 "llamada fantasma" **no** se mide por duración: es categoría del dataset gobernada por capa `callcenter`, si está identificada **no timbra** [DN-07]; PN#3 **festivos calculados y empaquetados** offline + override `app_params` [DN-06]; PN#4 auditoría de integridad **real por checksum** (reemplaza la simulación del prototipo) [DN-08]; PN#5 **importación masiva fuera de alcance** de la app → portal administrativo externo [DN-09]. RN-08 de `00-fundamentos` actualizada.
- [ ] **Spec `08-motor-franja-ley2300` creada (NO implementada).** `.kiro/specs/08-motor-franja-ley2300/` (requirements + design + tasks). Lleva al motor lo que la spec 05 dejó fuera: (1) hora local en `IncomingContact`, (2) `ColombianHolidays` calculado offline, (3) `Ley2300WindowRule` + ajuste del nivel 5 del `PrecedenceEngine` para bloquear comerciales fuera de franja, (4) **paridad nativa** en el `CallScreeningService` (bloqueo antes de timbrar), (5) `VerifyDatasetIntegrity` real por checksum. Mayor riesgo: trabajo nativo Kotlin (tarea 4). Reutiliza `core/legal/ley2300_hours.dart`, `PrecedenceEngine`/snapshot y el checksum del sync.

## 3. Dataset de bloqueo

- [ ] Activar **`domain_hashes`**: extracción de URL/dominio en SMS + matching. Estructura ya diseñada; activación diferida. [DA-06]
- [ ] **Reglas de contenido difuso** (`content_rules`): keywords/patrones locales. Fase futura. [DA-06]

## 4. Seguridad (hardening diferido)

- [ ] **Detección de root/jailbreak** (modelo "detectar y advertir"). Fuera del MVP. [DA-14]
- [ ] **Play Integrity attestation** (app/dispositivo genuino). Fuera del MVP. [DA-14]
- [ ] Documento de **modelo de amenazas formal (STRIDE)** — propuesto, aún no elaborado.
- [ ] Definir **procedimiento operativo de rotación de pepper** (hoy diseñado a nivel de versión; falta runbook). [DA-05]

## 5. Métricas (fase 2)

- [ ] Salud comunitaria detallada (reportes/día, % promovidos). [DA-01]
- [ ] Cobertura global vs. local. [DA-01]
- [ ] % escudo total/parcial/desactivado (usa RN-03). [DA-01]
- [ ] Opt-in rate de telemetría. [DA-01]
- [ ] **Falsos positivos** como contador agregado anónimo (opt-in, nunca el número). [DA-01]

## 6. Backend y operación

- [ ] **Segundo entorno** (dev/staging + prod) con proyectos Supabase y peppers separados + flavors. Hoy un solo entorno. [DA-15]
- [ ] **CI/CD** completo (build Flutter por flavor, deploy de Edge Functions y migraciones, gate de compatibilidad de API). [DA-16]
- [x] **Fix: permiso `INTERNET` en builds release.** Estaba solo en los manifests `debug`/`profile` (Flutter lo inyecta ahí para hot reload), así que el APK **release** quedaba sin red y la autenticación con Supabase fallaba (solo en release, no en debug). Resuelto declarándolo en `android/app/src/main/AndroidManifest.xml` (aplica a todos los builds). Verificado en el Moto g04s (`dumpsys package` → `INTERNET: granted=true`).
- [x] **Fix: `device_id` estable entre reinstalaciones (evita el falso "cambia de dispositivo").** El `device_id` era un UUID v4 en secure storage; al reinstalar (Flutter desinstala primero) se borraba y se generaba uno nuevo → el servidor lo veía como otro equipo y disparaba la exclusividad (DA-03). Ahora `DeviceIdStore` **deriva** el id de `Settings.Secure.ANDROID_ID` (estable entre reinstalaciones, sin permisos, no es IMEI/serial) mediante **UUID v5 determinista**: mismo equipo → mismo `device_id` siempre. No viaja PII de hardware en crudo (sale el UUID derivado), coherente con DA-02. Canal nativo `platform_device/getAndroidId` en `MainActivity`; `HardwareIdSource` degrada a `null` ante cualquier fallo (binding ausente en tests) → fallback a UUID v4. Instalaciones existentes se respetan (si ya hay id guardado, no se re-deriva). **Transición:** se limpiaron los 4 `devices` viejos del número de prueba `+573015970768` para que el nuevo id estable registre sin conflicto. 187 tests + analyze limpio; APK reinstalado en el Moto g04s. [DA-02, DA-03]
- [ ] **Keystore de release propia** pendiente: hoy el `release` firma con la **debug keystore** (`android/app/build.gradle`), suficiente para instalar en el equipo pero **no** para publicar (Play Store / distribución a terceros). Crear keystore propia + config de firma antes de distribuir. [DA-16]
- [ ] Confirmar **política de deprecación de versiones de API** (hoy sugerida: últimas 2 minor). [DA-15]
- [x] **Decidido · calendario de festivos colombianos** para la Ley 2300: se **calcula y empaqueta** en la app (determinista, offline: fijos + Emiliani + derivados de Pascua), con **override opcional por `app_params`** para decretos excepcionales. El bloqueo por franja/festivo es **siempre offline**. [DN-06, RN-08]. Implementación en la **spec `08-motor-franja-ley2300`** (aún no construida).

## 7. Fuera de alcance (otros proyectos)

- [ ] **Administración web** de organizaciones/allowlists (carga CSV/manual) — proyecto separado. [DA-10]
- [ ] **Billing** automático para exclusiones comerciales pagadas — proyecto separado. [DA-10]

---

## Pendientes recién añadidos (bandeja de entrada)

> Mover a la categoría correspondiente al procesarlos.

- [ ] (nada pendiente de clasificar)
