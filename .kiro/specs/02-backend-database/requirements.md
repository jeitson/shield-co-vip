# Spec · 02 Backend y Base de Datos — Requerimientos

> Backend real (Supabase) y esquema de base de datos de Cifrado Cero.
> Artefactos físicos: [`05-backend/`](../../../05-backend/) (proyecto Supabase, Edge Functions, config, deploy) y [`06-database/`](../../../06-database/) (migraciones SQL).
> Arquitectura: [`03-architecture`](../../../03-architecture/) (DA-01, DA-02, DA-03, DA-04, DA-05, DA-08, DA-10, DA-11, DA-15).

Esta spec cubre todo el backend del sistema, pero se **ejecuta por fases** acopladas a los flujos de pantallas. La **Fase 1 (MVP de autenticación)** es la única que se construye ahora; el resto queda diseñado y diferido.

---

## 1. Introducción

El backend se apoya en **Supabase** (Auth + Postgres/RLS + Edge Functions + pg_cron + Vault), con **toda la lógica de negocio y criptográfica en Edge Functions** (DA-11). El cliente nunca toca tablas sensibles ni el pepper directamente.

**Adaptación de carpetas (consciente):** la arquitectura (`01`/`06`) ubica el backend en `supabase/` en la raíz. Por organización del repo y a pedido del equipo, los artefactos viven en:
- `05-backend/supabase/` — `config.toml`, `functions/`, scripts y documentación de despliegue.
- `06-database/` — migraciones SQL versionadas (fuente de verdad del esquema), espejadas en `05-backend/supabase/migrations` para que la CLI de Supabase las aplique.

> La CLI de Supabase requiere las migraciones bajo `supabase/migrations`. Para no duplicar, `06-database/` es la fuente canónica y `05-backend/supabase/migrations` la referencia (symlink o copia documentada). Ver design §4.

---

## 2. Fases

| Fase | Alcance | Estado |
|------|---------|:---:|
| **1 · Auth MVP** | Supabase Auth, tabla `profiles`, trigger de alta, RLS de perfil, `app_params` base | **Se construye ahora** |
| 2 · Dispositivos y sesión | `devices`, `v1-session` (registro/activación/refresh 12h, DA-03/04) | Diferido |
| 3 · Dataset y cripto | `phone_hashes`, `allowlist_hashes`, `dataset_version`, Vault+pepper, `v1-pepper`, `v1-sync` (DA-05/08) | Diferido |
| 4 · Comunidad y métricas | `reports`, `metrics_daily`, `v1-report`, `v1-metrics`, pg_cron (DA-01/10) | Diferido |

El esquema de las fases 2–4 se **documenta** en el design para no rehacer decisiones, pero **no se crean** sus migraciones ni funciones todavía.

---

## 3. Requerimientos — Fase 1 (Auth MVP)

### R1 · Identidad gestionada por Supabase Auth
**Historia:** como sistema, quiero delegar registro/login/sesión/recuperación a Supabase Auth (DA-11, DN-01).

Criterios (EARS):
1. EL SISTEMA DEBERÁ permitir registro con correo + contraseña vía Supabase Auth.
2. EL SISTEMA DEBERÁ permitir login con correo + contraseña y emitir sesión (access + refresh token).
3. EL SISTEMA DEBERÁ permitir recuperación de clave por email (DA-04, `02-seguridad` §02.4).
4. EL SISTEMA DEBERÁ aceptar metadatos de alta (nombre, apellido, celular, consentimientos) en el `signUp` para poblar el perfil.

### R2 · Tabla `profiles` espejo de la cuenta
**Historia:** como sistema, quiero un perfil de dominio asociado 1:1 a `auth.users` (`00-fundamentos`, `03-datos` §03.1).

Criterios (EARS):
1. EL SISTEMA DEBERÁ tener una tabla `profiles` con `id` = `auth.users.id` (FK, on delete cascade).
2. EL SISTEMA DEBERÁ guardar `email`, `nombre`, `apellido`, `celular` (E.164 legible), `terminos_aceptados`, `privacidad_aceptada`, `telemetria_optin`, `created_at`.
3. CUANDO se crea un usuario en `auth.users`, EL SISTEMA DEBERÁ crear automáticamente su fila en `profiles` a partir de los metadatos del alta (trigger `handle_new_user`).
4. EL SISTEMA DEBERÁ fijar `telemetria_optin = false` por defecto (opt-in explícito, DA-01 / Ley 1581).

### R3 · Seguridad de acceso (RLS)
**Historia:** como sistema, quiero que cada usuario solo acceda a su propio perfil (DA-11, `03-datos` §03.2).

Criterios (EARS):
1. EL SISTEMA DEBERÁ habilitar RLS en `profiles`.
2. EL SISTEMA DEBERÁ permitir a un usuario autenticado **leer** solo la fila cuyo `id = auth.uid()`.
3. EL SISTEMA DEBERÁ permitir **actualizar** solo su propia fila y solo campos permitidos (no `id`, no `email` que gobierna Auth).
4. EL SISTEMA DEBERÁ impedir que el cliente inserte/borre perfiles directamente (el alta la hace el trigger con privilegios).

### R4 · Parámetros configurables base
**Historia:** como sistema, quiero una tabla `app_params` para constantes ajustables sin desplegar (`03-datos` §03.1, `05-backend` §05.5).

Criterios (EARS):
1. EL SISTEMA DEBERÁ crear `app_params(clave PK, valor, descripcion, publico bool)`.
2. EL SISTEMA DEBERÁ sembrar al menos `min_app_version` (política de actualización forzada, DA-15).
3. EL SISTEMA DEBERÁ permitir lectura por el cliente **solo** de claves marcadas `publico = true`; el resto, solo service role.

### R5 · Reproducibilidad y despliegue
**Historia:** como equipo, quiero migraciones versionadas y un proceso de despliegue documentado (DA-15, `06-entornos`).

Criterios (EARS):
1. EL SISTEMA DEBERÁ definir el esquema como **migraciones SQL versionadas** (no cambios manuales en el panel).
2. EL SISTEMA DEBERÁ documentar los pasos de despliegue (`supabase link`, `db push`, `functions deploy`).
3. EL SISTEMA DEBERÁ proveer un `.env.example` con todas las variables requeridas y **sin secretos reales**.
4. EL SISTEMA DEBERÁ documentar qué variables debe entregar el usuario para completar el despliegue.

### R6 · Integración con la app Flutter
**Historia:** como app, quiero autenticar contra Supabase real sin cambiar dominio ni UI (spec `01-autenticacion` §9).

Criterios (EARS):
1. EL SISTEMA DEBERÁ exponer una fuente remota real que implemente el contrato `AuthRemoteDataSource` existente.
2. EL SISTEMA DEBERÁ mapear la sesión de Supabase a `AuthSessionDto` (tokens + expiración + perfil).
3. EL SISTEMA DEBERÁ permitir seleccionar fuente real vs. fake por configuración de entorno, sin tocar el resto del código.
4. CUANDO el usuario inicie sesión con credenciales reales válidas, EL SISTEMA DEBERÁ navegar al Dashboard (CA-LOGIN-02 con backend real).

---

## 4. Fuera de alcance (esta fase)

- `devices`, `phone_hashes`, `allowlist_hashes`, `reports`, `metrics_daily`, `dataset_version` (Fases 2–4).
- Pepper/Vault y Edge Functions `v1-pepper`/`v1-sync`/`v1-report`/`v1-metrics` (Fases 3–4).
- Refresh de sesión 12h contra `devices` y exclusividad por número (DA-03/04) — Fase 2.
- OTP de celular (diferido, memory bank §2).
- Segundo entorno dev/prod y CI/CD (DA-15/16, memory bank §6).
