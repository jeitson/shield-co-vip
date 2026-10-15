# 05 · Backend — Supabase

Backend ejecutable de Cifrado Cero: proyecto Supabase (Auth + Postgres/RLS + Edge Functions), configuración y proceso de despliegue.

> Spec: [`.kiro/specs/02-backend-database/`](../.kiro/specs/02-backend-database/).
> Esquema de datos (fuente canónica): [`06-database/`](../06-database/).
> Arquitectura: [`03-architecture`](../03-architecture/) (DA-11 topología, DA-15 versionado).

---

## Estado actual — Fase 1 · Auth MVP

Lo que entra ahora:

- **Supabase Auth** (email + contraseña, recuperación por email).
- **Esquema mínimo**: `profiles` + trigger de alta + RLS + `app_params` (ver `06-database/`).
- **`v1-health`**: Edge Function de health-check que fija el patrón de API versionada (`/vN`). Sin lógica sensible.

Diferido a fases posteriores (diseñado en `06-database/schema/00-esquema-completo.md`): `devices`, pepper/Vault, `v1-session`, `v1-pepper`, `v1-sync`, `v1-report`, `v1-metrics`, `pg_cron`.

---

## Estructura

```
05-backend/
├── README.md            # este archivo
├── .env.example         # variables requeridas (sin secretos)
└── supabase/
    ├── config.toml       # config del proyecto (CLI)
    ├── migrations/       # espejo con timestamp de 06-database/migrations
    └── functions/
        └── v1-health/index.ts
```

> **Fuente canónica del esquema:** `06-database/migrations/` (`0001..0004`). Las copias en `supabase/migrations/` llevan prefijo de timestamp porque la CLI de Supabase lo exige. Si cambias el esquema, edita primero `06-database/` y vuelve a copiar (ver «Sincronizar migraciones»).

---

## Requisitos

1. **Supabase CLI** (no viene instalada en esta máquina):
   ```bash
   brew install supabase/tap/supabase
   # o ver https://supabase.com/docs/guides/cli
   ```
2. Una cuenta Supabase y un **proyecto creado** (plan free sirve para el MVP).
3. **Docker** solo si quieres correr Supabase local (`supabase start`); no es necesario para desplegar a un proyecto en la nube.

---

## Variables de entorno

Copia `.env.example` → `.env` y rellena. Resumen de quién usa qué:

| Variable | Pública | La usa |
|----------|:---:|--------|
| `SUPABASE_PROJECT_REF` | sí | `supabase link` |
| `SUPABASE_URL` | sí | app Flutter + CLI |
| `SUPABASE_ANON_KEY` | sí (RLS protege) | app Flutter |
| `SUPABASE_SERVICE_ROLE_KEY` | **NO (secreto)** | administración / CI |
| `SUPABASE_DB_PASSWORD` | **NO (secreto)** | `supabase db push` |

Los valores salen del panel: **Project Settings → API** (URL, anon key, service_role) y **Project Settings → Database** (password). El `project_ref` es el subdominio del proyecto.

---

## Despliegue paso a paso

```bash
# 1. Autenticar la CLI (abre el navegador)
supabase login

# 2. Enlazar el repo con tu proyecto Supabase
cd 05-backend
supabase link --project-ref "$SUPABASE_PROJECT_REF"

# 3. Aplicar el esquema (migraciones de supabase/migrations)
supabase db push

# 4. (Opcional, patrón de API) desplegar el health-check
supabase functions deploy v1-health
#    Verificar:
#    curl "$SUPABASE_URL/functions/v1/v1-health"

# 5. Configurar Auth en el panel:
#    - Authentication → Providers → Email: habilitado.
#    - Authentication → URL Configuration: Site URL y redirect del reset.
#    - (Opcional) Email templates en es-CO.
```

### Crear el usuario real de prueba

> **Nota:** el proyecto tiene **confirmación de email activada** por defecto. Un
> `signUp` normal crea la cuenta pero **no abre sesión** hasta confirmar el
> correo. Para desactivarlo: panel → Authentication → Providers → Email →
> "Confirm email" off.

Opciones:

- **Desde la app** (recomendado): completar el registro — ejercita el trigger
  `handle_new_user`. Si la confirmación está activa, habrá que confirmar el correo
  antes de poder iniciar sesión.
- **Desde el panel**: Authentication → Users → Add user.
- **Usuario confirmado para QA (sin buzón real)** vía Admin API con el
  `service_role`:
  ```bash
  curl -s "$SUPABASE_URL/auth/v1/admin/users" \
    -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Content-Type: application/json" \
    -d '{"email":"qa@ejemplo.com","password":"...","email_confirm":true,
         "user_metadata":{"nombre":"QA","apellido":"Test","celular":"+573001112233",
         "terminos_aceptados":true,"privacidad_aceptada":true}}'
  ```

### Desplegar sin access token personal

`supabase link` y `supabase functions deploy` requieren un **access token personal**
(`sbp_...`) de la cuenta (Account → Access Tokens), distinto del `service_role`.
Para aplicar **solo migraciones** sin ese token, usar la conexión directa:

```bash
set -a; source .env; set +a
ENC_PW=$(python3 -c "import urllib.parse,os;print(urllib.parse.quote(os.environ['SUPABASE_DB_PASSWORD'],safe=''))")
supabase db push --db-url "postgresql://postgres:${ENC_PW}@db.${SUPABASE_PROJECT_REF}.supabase.co:5432/postgres" --yes
```

### Validación

1. Registro/login con el usuario real → la app navega al Dashboard (CA-LOGIN-02).
2. `select * from public.profiles;` muestra la fila con los metadatos del alta.
3. Con otro usuario, confirmar que **no** puede leer el perfil ajeno (RLS).

---

## Sincronizar migraciones (canónico → CLI)

Tras editar `06-database/migrations/`, regenerar las copias con timestamp:

```bash
# desde la raíz del repo (ejemplo de convención; ajustar timestamps nuevos)
cp 06-database/migrations/0001_profiles.sql        05-backend/supabase/migrations/20260101000001_profiles.sql
cp 06-database/migrations/0002_profiles_rls.sql    05-backend/supabase/migrations/20260101000002_profiles_rls.sql
cp 06-database/migrations/0003_handle_new_user.sql 05-backend/supabase/migrations/20260101000003_handle_new_user.sql
cp 06-database/migrations/0004_app_params.sql      05-backend/supabase/migrations/20260101000004_app_params.sql
```

Para una migración **nueva**, usa `supabase migration new <nombre>` (genera el timestamp) y copia el SQL desde `06-database/`.

---

## Seguridad

- `anon key` es pública por diseño; la protección real es **RLS** (DA-11).
- `service_role` y `DB_PASSWORD` **nunca** se incrustan en la app ni se suben al repo. Solo en el entorno de despliegue/CI.
- Secretos criptográficos (pepper) irán en **Vault** en la Fase 3, no en `app_params` ni en `.env` de la app.
