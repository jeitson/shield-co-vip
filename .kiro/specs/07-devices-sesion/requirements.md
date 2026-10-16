# Spec · 07 Dispositivos y sesión — Requerimientos

> Subsistema de **dispositivos** (Fase 2): registro del dispositivo por cuenta,
> exclusividad de protección por número (DA-03), sesión de 12h con revocación
> (DA-04) y endurecimiento de `v1-sync`/`v1-pepper` para exigir "dispositivo
> activo". Es el **onboarding post-login** que faltaba.
>
> Fuente de arquitectura: [`00-resumen-y-decisiones`](../../../03-architecture/00-resumen-y-decisiones.md) DA-02/03/04,
> [`04-app-flutter`](../../../03-architecture/04-app-flutter.md) §04.6,
> [`05-backend-api-metricas`](../../../03-architecture/05-backend-api-metricas.md) §05.2.
> Esquema: [`06-database/schema/00-esquema-completo.md`](../../../06-database/schema/00-esquema-completo.md) (tabla `devices`).
> Depende de: `01-autenticacion` (sesión), `03-persistencia-local` (DEK/wipe),
> `04-dataset-sync` (pepper, v1-sync/v1-pepper a endurecer).

---

## 1. Introducción

Hoy el login abre sesión de Supabase Auth, pero **no** registra el dispositivo ni
aplica la exclusividad por número. La decisión B1 dejó `v1-sync`/`v1-pepper`
autenticados solo por sesión Auth; esta spec añade la capa de `devices` que la
arquitectura exige:

- **Registro de dispositivo** con `device_id` propio (UUID de instalación, DA-02),
  no PII de hardware.
- **Exclusividad por número** (DA-03, RN-DEV-02): un `numero_protegido` solo puede
  estar activo en un dispositivo a la vez; activar en otro revoca el anterior.
- **Sesión de 12h con revocación** (DA-04): el refresh verifica que el dispositivo
  siga `activo`; si no, falla y la app borra material sensible.

### Decisiones de alcance (confirmadas con el usuario)
- El **número protegido** = `profiles.celular` (el del registro). Sin pantalla nueva.
- **OTP de celular**: fuera de alcance (pendiente). No se verifica el número por SMS.
- Enganche: tras login, la app **registra el device automáticamente**; si el número
  ya está activo en otro dispositivo, muestra un **diálogo de exclusividad** y, al
  confirmar, revoca el anterior.
- La **revocación** borra pepper + DEK + dataset local (desprotegido → re-login).

---

## 2. Requerimientos — Backend (Supabase)

### R1 · Tabla `devices` + RLS
Criterios (EARS):
1. EL SISTEMA DEBERÁ crear `public.devices` (`id` UUID = device_id, `profile_id`
   FK, marca, modelo, so, so_version, app_version, idioma, zona_horaria,
   `estado` activo|revocado, `numero_protegido`, `last_synced_version`,
   `last_seen_at`, `created_at`) según `03-datos` §03.1.
2. EL SISTEMA DEBERÁ aplicar RLS: el usuario **lee solo sus propios dispositivos**;
   la **escritura** pasa por Edge Functions (service role), no directa del cliente.

### R2 · `v1-session/register-device`
Criterios (EARS):
1. CUANDO un cliente autenticado registra su dispositivo, EL SISTEMA DEBERÁ
   crear/actualizar la fila `devices` con sus metadatos y asociarla al `profile_id`
   del JWT.
2. CUANDO el `numero_protegido` **no** está activo en otro dispositivo, EL SISTEMA
   DEBERÁ marcar este dispositivo `activo` y responder `{ estado: "activo" }`.
3. CUANDO el `numero_protegido` **ya** está activo en **otro** dispositivo, EL
   SISTEMA DEBERÁ responder `{ estado: "pendiente_confirmacion",
   warning: "numero_protegido_en_otro_dispositivo" }` **sin** revocar aún.
4. CUANDO el mismo dispositivo (mismo `device_id`) re-registra, EL SISTEMA DEBERÁ
   ser idempotente (actualiza metadatos, conserva estado).

### R3 · `v1-session/activate` (confirmar exclusividad, DA-03)
Criterios (EARS):
1. CUANDO el usuario confirma tomar la protección, EL SISTEMA DEBERÁ marcar el
   dispositivo anterior `revocado` y este `activo`, respondiendo
   `{ estado: "activo", revocado: "<device_id_anterior>" }`.
2. EL SISTEMA DEBERÁ garantizar que, al terminar, **solo un** dispositivo tenga
   ese `numero_protegido` en estado `activo` (RN-DEV-02).

### R4 · `v1-session/refresh` (revocación 12h, DA-04)
Criterios (EARS):
1. CUANDO un cliente pide refresh y su dispositivo sigue `activo`, EL SISTEMA
   DEBERÁ responder OK (`{ estado: "activo" }`) y actualizar `last_seen_at`.
2. CUANDO el dispositivo fue `revocado`, EL SISTEMA DEBERÁ responder **401**
   `{ error: "device_revocado" }`.
3. SI no hay sesión Auth válida, EL SISTEMA DEBERÁ responder 401.

### R5 · Endurecer `v1-sync` y `v1-pepper`
Criterios (EARS):
1. CUANDO un cliente pide `v1-sync`/`v1-pepper` con un dispositivo **no activo**
   (revocado o no registrado), EL SISTEMA DEBERÁ **denegar** (401/403), no
   entregar pepper ni dataset.
2. EL SISTEMA DEBERÁ identificar el dispositivo por un header/parámetro
   (`x-device-id`) validado contra `devices` del `profile_id` del JWT.

---

## 3. Requerimientos — App (Flutter)

### R6 · `device_id` de instalación (DA-02)
Criterios (EARS):
1. CUANDO la app arranca por primera vez, EL SISTEMA DEBERÁ generar un **UUID de
   instalación** y guardarlo en secure storage (no IMEI/Android ID).
2. EL SISTEMA DEBERÁ reutilizar ese `device_id` en arranques posteriores y
   enviarlo en las llamadas a `v1-session`/`v1-sync`/`v1-pepper`.

### R7 · Registro automático tras login
Criterios (EARS):
1. CUANDO el login/registro tiene éxito, EL SISTEMA DEBERÁ llamar
   `register-device` con el `device_id`, los metadatos del dispositivo y el
   `numero_protegido` (= celular del perfil).
2. CUANDO la respuesta es `pendiente_confirmacion`, EL SISTEMA DEBERÁ mostrar un
   **diálogo de exclusividad** explicando que el número está protegido en otro
   dispositivo y que continuar revocará aquel.
3. CUANDO el usuario confirma, EL SISTEMA DEBERÁ llamar `activate` y continuar al
   Dashboard; si cancela, EL SISTEMA DEBERÁ no activar y mantenerlo degradado o
   volver a login (según elección).

### R8 · Refresh con revocación y wipe (DA-04)
Criterios (EARS):
1. CUANDO la app arranca con sesión persistida, EL SISTEMA DEBERÁ llamar
   `refresh`; si responde `device_revocado`, DEBERÁ **borrar material sensible**
   (pepper, DEK, dataset local) y volver a `login` (desprotegido).
2. EL SISTEMA DEBERÁ ejecutar el refresh también de forma periódica/oportuna
   (al menos una vez al día, coherente con la ventana de 12h).
3. CUANDO el wipe ocurre, EL SISTEMA DEBERÁ dejar la app en un estado consistente
   (base local vacía recreada, sin pepper), sin crashear.

### R9 · Enviar `x-device-id` en sync/pepper
Criterios (EARS):
1. EL SISTEMA DEBERÁ añadir el header `x-device-id` en las llamadas a
   `v1-sync`/`v1-pepper` (vía el interceptor existente), para que el backend
   verifique "dispositivo activo" (R5).

---

## 4. Verificación

- **Backend:** registrar device A (activo) → registrar mismo número en device B
  (pendiente_confirmacion) → activate B (A revocado, B activo) → refresh A → 401
  device_revocado; `v1-sync` con device revocado → denegado; con device activo → OK.
- **App (unit):** generación/persistencia del `device_id`; mapeo de respuestas de
  `register-device`/`activate`/`refresh`; wipe en revocación (borra pepper/DEK/dataset).
- **Dispositivo:** login en el Moto g04s registra el device; el refresh mantiene
  la sesión; (opcional) simular revocación desde backend y ver el wipe + re-login.

---

## 5. Fuera de alcance (esta spec)

- **OTP de celular** (verificación del número por SMS): pendiente (DA-04).
- Pantalla de **perfil/cuenta** y gestión de múltiples dispositivos (listar/revocar
  manualmente): es parte del shell/perfil (08.7, pregunta abierta), no de esta spec.
- Push / deep links.
