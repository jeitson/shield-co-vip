-- 0006_dataset_rls.sql
-- RLS del dataset (Fase 3). Línea de defensa en profundidad [DA-11].
--
-- El cliente NUNCA lee `phone_hashes` ni `dataset_version` directo por la API
-- REST de Supabase: obtiene el dataset SOLO vía la Edge Function `v1-sync`
-- (que corre con service role). Por eso habilitamos RLS y NO creamos ninguna
-- policy para el rol autenticado/anon → acceso denegado por defecto.
-- Ref: 03-architecture/03-datos-y-sincronizacion.md §03.2.

alter table public.phone_hashes enable row level security;
alter table public.dataset_version enable row level security;

-- Sin policies: ni anon ni authenticated pueden leer/escribir estas tablas por
-- REST. El service role (Edge Functions) ignora RLS y es la única vía de acceso.
-- Se dejan `drop policy if exists` por idempotencia ante futuros cambios.
drop policy if exists "phone_hashes_no_client" on public.phone_hashes;
drop policy if exists "dataset_version_no_client" on public.dataset_version;
