# Spec · 07 Dispositivos y sesión — Diseño

> Backend (tabla `devices` + RLS + `v1-session`) + app (`device_id`, registro
> post-login, refresh con wipe, header `x-device-id`). Alineado a DA-02/03/04.

---

## 1. Backend (Supabase)

### 1.1 Migración `0008_devices.sql` (`06-database` + copia CLI)

- `public.devices`:
  - `id uuid primary key` (= device_id de instalación, DA-02).
  - `profile_id uuid not null references profiles(id) on delete cascade`.
  - `marca, modelo, so, so_version, app_version, idioma, zona_horaria text`.
  - `estado text not null default 'activo' check (estado in ('activo','revocado'))`.
  - `numero_protegido text` (= celular del perfil).
  - `last_synced_version int not null default 0`.
  - `last_seen_at timestamptz`, `created_at timestamptz default now()`.
  - Índice parcial para la exclusividad: facilitar "¿quién tiene este número
    activo?" → `create index on devices(numero_protegido) where estado = 'activo'`.
- RLS: `select` solo `profile_id = auth.uid()`; **sin** policies de insert/update
  para el cliente (escritura solo vía Edge/service role). (`03-datos` §03.2.)

### 1.2 Edge Function `v1-session/` (un solo endpoint con acción)

Para no multiplicar funciones, `v1-session` enruta por `action` en el body (o por
subruta). Valida el JWT (como `v1-sync`) y usa service role para escribir `devices`.

- `action: "register"` → upsert del device del `profile_id`. Calcula exclusividad:
  - ¿hay **otro** device (`id != device_id`) con el mismo `numero_protegido` y
    `estado='activo'`? → responde `pendiente_confirmacion` (no activa este).
  - si no → marca este `activo`, responde `activo`.
- `action: "activate"` → en una transacción: revoca el/los otros activos con ese
  número y activa este. Responde `{ estado: activo, revocado }`.
- `action: "refresh"` → si este device está `activo`, actualiza `last_seen_at` y
  responde OK; si `revocado` → 401 `device_revocado`.

> Idempotencia: `register` del mismo `device_id` actualiza metadatos sin duplicar.
> Un helper `requireDevice(req)` extrae `x-device-id` + valida pertenencia al JWT.

### 1.3 Endurecer `v1-sync` y `v1-pepper`

Añadir en ambas: leer `x-device-id`, verificar que exista una fila `devices` de
ese `profile_id` con `estado='activo'`. Si no → `403 device_inactivo`. Reutiliza
el helper `requireActiveDevice`. El resto de la lógica no cambia.

---

## 2. App (Flutter)

```
features/device/
├── data/
│   ├── device_id_store.dart        # UUID de instalación en secure storage
│   ├── device_info_provider.dart   # marca/modelo/SO (device_info_plus)
│   ├── session_remote_data_source.dart  # v1-session (register/activate/refresh)
│   └── device_repository_impl.dart
├── domain/
│   ├── device_registration.dart    # resultado: activo | pendiente | revocado
│   └── device_repository.dart
└── presentation/
    ├── device_providers.dart
    └── exclusivity_dialog.dart      # diálogo de advertencia (DA-03)
core/secure/
└── (device_id reutiliza secureStorageProvider)
```

### 2.1 `device_id` (DA-02)

`DeviceIdStore`: lee/crea un UUID v4 bajo `device_id_v1` en secure storage. Se
genera con `crypto`/`Random.secure` (sin dependencia nueva; UUID simple) o
`uuid` si se prefiere. Nunca IMEI/Android ID.

### 2.2 Metadatos del dispositivo

`device_info_plus` (dep nueva) para marca/modelo/SO/versión; `app_version` del
`kAppVersion`; idioma/zona del `Platform`/`intl`. Se arma un `DeviceInfo` para el
`register`.

### 2.3 Registro post-login (R7)

Un `DeviceRegistration` orquestado tras `authStatus == authenticated`:
1. `register-device(device_id, info, numero_protegido = perfil.celular)`.
2. Si `pendiente_confirmacion` → `ExclusivityDialog` (explica + confirmar/cancelar).
   - confirmar → `activate` → continuar.
   - cancelar → no activa (queda desprotegido / vuelve a login).
3. Si `activo` → continuar al Dashboard.

Se integra en el arranque autenticado (p. ej. en el guard del router o en el
`SessionNotifier`), sin romper el flujo actual de auth.

### 2.4 Refresh con wipe (R8, DA-04)

Se amplía `restoreSession()`/`SessionNotifier`: tras restaurar una sesión válida,
llamar `refresh`. Si `device_revocado`:
- Borrar **pepper** (`PepperStore.clear`), **DEK** (`LocalCryptoKeys.deleteDek`),
  **dataset** (`PhoneHashesDao.clearAll` o recrear base) y la sesión (`logout`).
- Emitir estado desprotegido → el router va a `login`.
Un `SessionWiper` centraliza el borrado para reutilizarlo (logout duro).

### 2.5 Header `x-device-id` (R9)

El `SupabaseAuthInterceptor` (o uno nuevo encadenado) añade `x-device-id` leído
del `DeviceIdStore` a cada request de sync/pepper/session.

### 2.6 Dependencias nuevas

- `device_info_plus` (metadatos del dispositivo).
- `uuid` (opcional; o generar el UUID con `Random.secure`). Se decide en impl.

---

## 3. Pruebas

- **Backend (integración tras desplegar):** flujo A activo → B pendiente →
  activate B → A refresh 401 `device_revocado`; `v1-sync` con device revocado → 403.
- **App (unit):**
  - `DeviceIdStore`: crea una vez, reutiliza.
  - `DeviceRepositoryImpl`: mapea register/activate/refresh; detecta pendiente;
    en revocado dispara el wipe (con stores falsos verifica que se llamó clear).
  - `SessionWiper`: borra pepper + DEK + dataset.
- `flutter analyze` + `dart format` + suite completa.
- **Dispositivo:** login en Moto g04s registra el device (fila en `devices`),
  el refresh mantiene sesión.

---

## 4. Nota de seguridad

El `device_id` es un UUID propio, no PII de hardware (DA-02). La revocación como
mecanismo de seguridad (DA-04) garantiza que un dispositivo perdido/robado pierde
el acceso al pepper en ≤12h y, al fallar el refresh, borra el material sensible
local. La exclusividad por número (DA-03) evita clonar la protección en silencio.
