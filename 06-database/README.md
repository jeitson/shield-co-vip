# 06 · Base de datos — Esquema y migraciones

Fuente **canónica** del esquema de datos de Cifrado Cero (Supabase/Postgres). Las migraciones viven aquí como SQL versionado y se aplican con la CLI de Supabase (nunca cambios manuales en el panel, DA-15).

> Spec asociada: [`.kiro/specs/02-backend-database/`](../.kiro/specs/02-backend-database/).
> Modelo de referencia: [`03-architecture/03-datos-y-sincronizacion.md`](../03-architecture/03-datos-y-sincronizacion.md).

---

## Organización

```
06-database/
├── migrations/        # SQL versionado (fuente canónica)
│   ├── 0001_profiles.sql
│   ├── 0002_profiles_rls.sql
│   ├── 0003_handle_new_user.sql
│   └── 0004_app_params.sql
└── schema/
    └── 00-esquema-completo.md   # ERD completo (fases 1–4) de referencia
```

El backend ejecutable (config de proyecto, Edge Functions, despliegue) está en [`05-backend/`](../05-backend/). La CLI de Supabase exige las migraciones bajo `supabase/migrations`, así que `05-backend/supabase/migrations/` contiene **copias con prefijo de timestamp** de estos archivos (ver `05-backend/README.md`).

## Convención de migraciones

- Numeración incremental `NNNN_nombre.sql`. Nunca se edita una migración ya aplicada; los cambios van en una migración nueva.
- SQL **idempotente** donde es seguro (`create table if not exists`, `drop policy if exists ... create policy`), para re-aplicar sin romper.
- Comentarios `comment on` para documentar tablas/columnas en la propia DB.

## Estado actual (Fase 1 · Auth MVP)

Existen físicamente:

| Objeto | Migración | Propósito |
|--------|-----------|-----------|
| `public.profiles` | 0001 | Perfil 1:1 con `auth.users` |
| `set_updated_at()` + trigger | 0001 | Mantener `updated_at` |
| RLS de `profiles` | 0002 | Lectura/edición solo del propio perfil |
| `handle_new_user()` + trigger | 0003 | Crear perfil al alta de Auth |
| `public.app_params` + RLS + seed | 0004 | Parámetros ajustables; `min_app_version` |

El resto del modelo (`devices`, `phone_hashes`, `allowlist_hashes`, `reports`, `metrics_daily`, `dataset_version`) está **diseñado** en `schema/00-esquema-completo.md` pero **no** migrado todavía (fases 2–4).

## Aplicar las migraciones

Ver el proceso completo en [`05-backend/README.md`](../05-backend/README.md). Resumen:

```bash
# desde 05-backend/
supabase link --project-ref <PROJECT_REF>
supabase db push
```

## Validación rápida (tras aplicar)

1. Registrar un usuario (por la app o el panel de Auth).
2. Verificar que aparece una fila en `public.profiles` con los metadatos.
3. Confirmar RLS: un usuario no puede leer el perfil de otro.
