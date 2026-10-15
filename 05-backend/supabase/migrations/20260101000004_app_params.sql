-- 0004_app_params.sql
-- Parámetros configurables sin desplegar (Fase 1 · base).
--
-- Constantes de negocio ajustables en caliente. Solo las claves marcadas
-- `publico = true` son legibles por el cliente vía RLS; el resto, service role.
-- Ref: 03-architecture/03-datos §03.1; 05-backend-api-metricas §05.5 [DA-15].

create table if not exists public.app_params (
  clave        text primary key,
  valor        text not null,
  descripcion  text,
  publico      boolean not null default false,
  updated_at   timestamptz not null default now()
);

comment on table public.app_params is
  'Parámetros ajustables sin desplegar (umbral de reportes, constantes de tiempo ahorrado, min_app_version, etc.). Secretos NO van aquí (usar Vault).';

alter table public.app_params enable row level security;

-- Solo lectura de las claves públicas; escritura solo service role (sin policy).
drop policy if exists "params_publicos_select" on public.app_params;
create policy "params_publicos_select" on public.app_params
  for select
  using (publico = true);

-- Seed mínimo: versión mínima soportada (política de actualización forzada).
insert into public.app_params (clave, valor, descripcion, publico) values
  ('min_app_version', '1.0.0', 'Versión mínima de app soportada; por debajo se fuerza actualización (DA-15).', true)
on conflict (clave) do nothing;
