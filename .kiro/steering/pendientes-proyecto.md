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
- [ ] **Confirmación de email:** el proyecto real la tiene **activada**. Decidir si se mantiene (registro requiere confirmar correo) o se desactiva en el panel para login inmediato. El flujo de confirmación/reenvío en la app no está construido aún.
- [x] **Edge Function `v1-health` desplegada** y respondiendo (HTTP 200 en `${SUPABASE_URL}/functions/v1/v1-health`). Confirma el patrón de API versionada y el pipeline de deploy de funciones. Requirió un access token personal (`sbp_...`) en `SUPABASE_ACCESS_TOKEN`.
- [ ] **Refresh de sesión 12h** contra `devices`: `restoreSession` descarta sesiones expiradas; falta el refresh real y la caída a "desprotegido" ante revocación (Fase 2 de `02-backend-database`). [DA-04]
- [ ] **OTP de verificación de celular** en registro (diseñado, no implementado en MVP). Definir proveedor SMS (Twilio u otro) y costo. [DA-04]
- [ ] Confirmar **política de contraseñas** (hoy solo longitud ≥ 8; `Password` VO preparado para endurecer sin cambiar contrato). Pregunta abierta de `01-autenticacion.md`.
- [ ] Confirmar **alcance geográfico** (hoy +57 fijo en `ColombianPhone`; ¿multi-país a futuro?). RN-REG-01.

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
- [ ] Confirmar **política de deprecación de versiones de API** (hoy sugerida: últimas 2 minor). [DA-15]
- [ ] Definir **calendario de festivos colombianos** para la Ley 2300 (fuente local empaquetada y/o actualizable). Pregunta abierta de `00-modelo-dominio.md` RN-08.

## 7. Fuera de alcance (otros proyectos)

- [ ] **Administración web** de organizaciones/allowlists (carga CSV/manual) — proyecto separado. [DA-10]
- [ ] **Billing** automático para exclusiones comerciales pagadas — proyecto separado. [DA-10]

---

## Pendientes recién añadidos (bandeja de entrada)

> Mover a la categoría correspondiente al procesarlos.

- [ ] (nada pendiente de clasificar)
