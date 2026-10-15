# Spec · 02 Backend y Base de Datos — Plan de implementación

> Fase 1 (Auth MVP). Las fases 2–4 se planifican cuando llegue su flujo.

- [x] 1. Base de datos (`06-database/`)
  - [x] 1.1 `README.md` con modelo de datos y convenciones de migración.
  - [x] 1.2 `migrations/0001_profiles.sql` — tabla `profiles`.
  - [x] 1.3 `migrations/0002_profiles_rls.sql` — RLS select/update propios.
  - [x] 1.4 `migrations/0003_handle_new_user.sql` — trigger de alta.
  - [x] 1.5 `migrations/0004_app_params.sql` — tabla + seed `min_app_version`.
  - [x] 1.6 `schema/00-esquema-completo.md` — ERD completo (fases 1–4) de referencia.
  - _Req: R2, R3, R4, R5.1_

- [x] 2. Backend (`05-backend/`)
  - [x] 2.1 `supabase/config.toml` — config del proyecto.
  - [x] 2.2 `supabase/migrations/` — copias con timestamp de las migraciones canónicas.
  - [x] 2.3 `supabase/functions/v1-health/index.ts` — health-check (patrón /vN). **Desplegada y verificada** (HTTP 200 en `/functions/v1/v1-health`).
  - [x] 2.4 `README.md` — arquitectura backend + proceso de despliegue paso a paso.
  - [x] 2.5 `.env.example` — variables requeridas sin secretos (+ `.gitignore`).
  - _Req: R1, R5_

- [ ] 3. Integración app Flutter
  - [x] 3.1 Añadir `supabase_flutter` a `pubspec.yaml`.
  - [x] 3.2 Extender `AppConfig` con `supabaseUrl`/`supabaseAnonKey` (vía dart-define) + `hasSupabase`.
  - [x] 3.3 Inicializar Supabase en `bootstrap` cuando haya config.
  - [x] 3.4 `AuthRemoteDataSourceSupabase implements AuthRemoteDataSource` (signUp/signIn/reset + mapeo de errores).
  - [x] 3.5 `authRemoteDataSourceProvider` elige real vs. fake según config.
  - [x] 3.6 Recuperación de clave real por email (diálogo con campo de correo → use case).
  - _Req: R6; spec 01 §9_

- [x] 4. Verificación y despliegue
  - [x] 4.1 `flutter analyze` + `flutter test` (siguen con fake, sin red). → limpio, 35 tests OK.
  - [x] 4.2 Informar al usuario las variables `.env` a proveer.
  - [x] 4.3 Desplegadas las 4 migraciones al proyecto real (`supabase db push --db-url`), verificado por REST: `app_params` con seed, `profiles` + trigger pueblan en signup, RLS activo. Login real validado (signUp + signInWithPassword → access_token). Usuarios de prueba creados y borrados; tabla limpia.
  - _Req: R5, R6, CA-LOGIN-02_

> **Hallazgo del despliegue:** el proyecto Supabase real tiene **confirmación de
> email activada** (distinto del `config.toml` local). Por eso un `signUp` normal
> no abre sesión hasta confirmar el correo — comportamiento ya contemplado en
> `AuthRemoteDataSourceSupabase` (mensaje "revisa tu correo"). Para QA sin buzón
> real, crear usuarios confirmados con la Admin API (`email_confirm: true`).
> Si se quiere registro con login inmediato, desactivar "Confirm email" en
> Authentication → Providers → Email del panel.
