# Spec · 02 Backend y Base de Datos — Diseño

> Diseño técnico del backend Supabase y el esquema de datos. Fase 1 (Auth MVP)
> se construye ahora; Fases 2–4 quedan diseñadas y diferidas.

---

## 1. Topología (DA-11)

```
Supabase (un proyecto, entorno único — DA-15)
├── Auth            → identidad: signUp / signIn / refresh / resetPassword
├── Postgres + RLS  → profiles (Fase 1); devices/hashes/... (fases futuras)
├── Edge Functions  → lógica de negocio y cripto (toca el pepper). Fase 1: no imprescindible.
├── pg_cron         → tareas programadas (Fase 4)
└── Vault           → pepper y secretos (Fase 3)
```

**Decisión de Fase 1:** la autenticación de la app se resuelve con el **SDK/HTTP de Supabase Auth directamente** (signUp/signIn con metadatos + RLS sobre `profiles`). No requiere Edge Functions todavía; estas entran cuando aparezca el pepper y la lógica sensible (Fase 3). Esto mantiene el MVP simple y desplegable rápido, coherente con "lo mínimo necesario".

> Se deja la carpeta `functions/` creada con un health-check `v1-health` para fijar el patrón de Edge Functions versionadas por carpeta (DA-15) y validar el toolchain de deploy, sin meter lógica sensible aún.

---

## 2. Estructura de carpetas

```
05-backend/
├── README.md                     # arquitectura backend + proceso de despliegue
├── .env.example                  # variables requeridas (sin secretos reales)
└── supabase/
    ├── config.toml               # config del proyecto (CLI)
    ├── migrations/               # espejo de 06-database (lo que aplica la CLI)
    └── functions/
        └── v1-health/            # health-check (patrón de Edge Functions /vN)
            └── index.ts

06-database/
├── README.md                     # modelo de datos + convenciones de migración
├── migrations/
│   ├── 0001_profiles.sql         # tabla profiles + índices
│   ├── 0002_profiles_rls.sql     # RLS de profiles
│   ├── 0003_handle_new_user.sql  # trigger de alta auth.users → profiles
│   └── 0004_app_params.sql       # app_params + seed min_app_version
└── schema/
    └── 00-esquema-completo.md     # ERD completo (fases 1–4) para referencia
```

- **`06-database/migrations/`** es la **fuente canónica** del esquema. Numeración incremental `NNNN_nombre.sql`.
- **`05-backend/supabase/migrations/`** contiene las mismas migraciones (la CLI de Supabase exige `supabase/migrations` con timestamp). Para no desincronizar, el README documenta copiar/symlinkar y la convención; en este repo se mantienen copias con prefijo de timestamp compatible con la CLI.

---

## 3. Esquema — Fase 1

### Tabla `profiles`

```sql
create table public.profiles (
  id                   uuid primary key references auth.users(id) on delete cascade,
  email                text not null,
  nombre               text not null,
  apellido             text not null,
  celular              text,                         -- E.164 legible (+57...)
  terminos_aceptados   boolean not null default false,
  privacidad_aceptada  boolean not null default false,
  telemetria_optin     boolean not null default false,  -- opt-in explícito (DA-01)
  created_at           timestamptz not null default now()
);
```

### Trigger de alta `handle_new_user`

Al crear un usuario en `auth.users`, se inserta su perfil leyendo los
`raw_user_meta_data` que la app envía en el `signUp` (nombre, apellido, celular,
consentimientos). `security definer` para saltarse RLS en la inserción del alta.

```sql
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, nombre, apellido, celular,
                               terminos_aceptados, privacidad_aceptada)
  values (new.id, new.email,
          coalesce(new.raw_user_meta_data->>'nombre', ''),
          coalesce(new.raw_user_meta_data->>'apellido', ''),
          new.raw_user_meta_data->>'celular',
          coalesce((new.raw_user_meta_data->>'terminos_aceptados')::boolean, false),
          coalesce((new.raw_user_meta_data->>'privacidad_aceptada')::boolean, false));
  return new;
end; $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
```

### RLS de `profiles`

```sql
alter table public.profiles enable row level security;

create policy "perfil_propio_select" on public.profiles
  for select using (auth.uid() = id);

create policy "perfil_propio_update" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);
-- Sin policy de insert/delete para el cliente: el alta la hace el trigger
-- (security definer) y el borrado lo gobierna el cascade de auth.users.
```

### `app_params`

```sql
create table public.app_params (
  clave        text primary key,
  valor        text not null,
  descripcion  text,
  publico      boolean not null default false
);

alter table public.app_params enable row level security;
create policy "params_publicos_select" on public.app_params
  for select using (publico = true);

insert into public.app_params (clave, valor, descripcion, publico) values
  ('min_app_version', '1.0.0', 'Versión mínima soportada (fuerza update, DA-15)', true);
```

### ERD completo (referencia, fases 2–4)

El documento `06-database/schema/00-esquema-completo.md` contiene el ERD íntegro
de `03-datos` §03.1 (`devices`, `phone_hashes`, `allowlist_hashes`, `reports`,
`app_params`, `metrics_daily`, `dataset_version`) para guiar las fases futuras,
marcando qué existe físicamente hoy (solo `profiles` + `app_params`).

---

## 4. Autenticación — contrato con la app (Fase 1)

La app usa el paquete **`supabase_flutter`** (SDK oficial). Flujo:

- **Registro:** `supabase.auth.signUp(email, password, data: { nombre, apellido, celular, terminos_aceptados, privacidad_aceptada })`. El trigger crea el perfil.
- **Login:** `supabase.auth.signInWithPassword(email, password)`.
- **Recuperación:** `supabase.auth.resetPasswordForEmail(email)`.
- **Sesión:** el SDK entrega `Session` con `accessToken`, `refreshToken`, `expiresAt`. Se mapea a `AuthSessionDto`; el perfil se lee de `profiles` por RLS tras autenticar.

`AuthRemoteDataSourceSupabase implements AuthRemoteDataSource` traduce estas
llamadas a `Result<AuthSessionDto>`, con mapeo de errores de Supabase (credenciales
inválidas, email duplicado, red) a los `Failure` existentes. **Dominio, controllers
y UI no cambian.**

### Selección de fuente por entorno

`authRemoteDataSourceProvider` elige según `AppConfig`:
- Si hay `supabaseUrl`/`supabaseAnonKey` configurados → `AuthRemoteDataSourceSupabase`.
- Si no (p. ej. tests, desarrollo offline) → `AuthRemoteDataSourceFake`.

El cliente Supabase se inicializa en el arranque (`bootstrap`) con las variables
de entorno; el `anonKey` es público por diseño (RLS protege los datos).

---

## 5. Configuración y secretos

| Variable | Dónde | Secreto | Uso |
|----------|-------|:---:|-----|
| `SUPABASE_URL` | app + backend | No | URL del proyecto (`https://<ref>.supabase.co`) |
| `SUPABASE_ANON_KEY` | app | No (público) | Cliente autenticado por RLS |
| `SUPABASE_SERVICE_ROLE_KEY` | solo backend/CI | **Sí** | Migraciones/admin; nunca en la app |
| `SUPABASE_DB_PASSWORD` | solo CI/deploy | **Sí** | `supabase db push` |
| `SUPABASE_PROJECT_REF` | deploy | No | `supabase link` |

- La app recibe `SUPABASE_URL` y `SUPABASE_ANON_KEY` vía `--dart-define` (o `--dart-define-from-file`), **no** se hardcodean en el repo.
- El `service_role` y la contraseña de DB **nunca** tocan la app ni el control de versiones; viven en el entorno de despliegue/CI.

---

## 6. Despliegue (resumen; detalle en `05-backend/README.md`)

1. `supabase login` y `supabase link --project-ref <ref>`.
2. `supabase db push` (aplica migraciones de `06-database`).
3. (Opcional Fase 1) `supabase functions deploy v1-health`.
4. Configurar Auth: habilitar email/password, URL de redirección para reset, plantillas en es-CO.
5. Crear un **usuario real** de prueba (vía la app o el panel) y validar login.

---

## 7. Pruebas

- **App:** las pruebas existentes siguen con el fake (sin red). Se añade un test del mapeo de errores de la fuente Supabase si se puede aislar sin red.
- **DB:** las migraciones se validan aplicándolas en el proyecto (o `supabase db reset` local si hay Docker). Verificar que el alta por Auth crea la fila en `profiles` y que RLS impide ver perfiles ajenos.
- **Manual (con backend desplegado):** registro de usuario real → aparece en `profiles`; login → navega al Dashboard; reset → llega correo.
