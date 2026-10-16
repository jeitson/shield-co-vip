-- 0005_dataset.sql
-- Dataset de bloqueo distribuido (Fase 3 · dataset + delta sync).
--
-- `phone_hashes` guarda las firmas de números peligrosos. Al dispositivo solo
-- viaja el `hash` (HMAC-SHA256 del número con el pepper de Vault); el
-- `numero_legible` existe SOLO server-side (RN-01 Zero-Knowledge). El versionado
-- por secuencia (`added_at_version` / `removed_at_version`) habilita el delta
-- sync idempotente [DA-08]. `dataset_version` es el contador global singleton.
-- Ref: 03-architecture/03-datos-y-sincronizacion.md §03.1/§03.3/§03.4.

-- Contador global del dataset (singleton: siempre una fila con id = 1).
create table if not exists public.dataset_version (
  id               int primary key default 1,
  current_version  int not null default 0,
  pepper_version   int not null default 1,
  updated_at       timestamptz not null default now(),
  constraint dataset_version_singleton check (id = 1)
);

comment on table public.dataset_version is
  'Contador global del dataset (singleton id=1). current_version se incrementa con cada alta/baja; pepper_version marca la rotación del pepper (full-resync).';

insert into public.dataset_version (id, current_version, pepper_version)
values (1, 0, 1)
on conflict (id) do nothing;

-- Firmas de números peligrosos.
create table if not exists public.phone_hashes (
  id                 bigint generated always as identity primary key,
  -- HMAC-SHA256(pepper, numero_normalizado_E164), en hex. Opaco para el cliente.
  hash               text not null,
  -- Visible SOLO server-side (moderación/auditoría). Nunca se envía al device.
  numero_legible     text not null,
  categoria          text not null,
  nivel              text not null check (nivel in ('ALTO', 'MEDIO', 'BAJO')),
  added_at_version   int not null,
  removed_at_version int,            -- null = activa (soft delete para el delta)
  pepper_version     int not null default 1,
  created_at         timestamptz not null default now()
);

comment on table public.phone_hashes is
  'Firmas de números peligrosos. Al dispositivo solo viaja hash+categoria+nivel; numero_legible es server-side (RN-01). Soft delete por removed_at_version [DA-08].';
comment on column public.phone_hashes.numero_legible is
  'Número legible del infractor; NUNCA se distribuye al dispositivo. Solo moderación server-side.';

-- Un mismo número puede re-hashearse al rotar el pepper: único por (hash, pepper_version).
create unique index if not exists uq_phone_hashes_hash_pepper
  on public.phone_hashes (hash, pepper_version);

-- Índices para el cálculo del delta (altas/bajas por versión).
create index if not exists idx_phone_hashes_added
  on public.phone_hashes (added_at_version);
create index if not exists idx_phone_hashes_removed
  on public.phone_hashes (removed_at_version);

-- Parámetro: gap de versión a partir del cual se exige full resync (05.5).
insert into public.app_params (clave, valor, descripcion, publico) values
  ('sync_full_gap', '500', 'Gap de versión a partir del cual el cliente hace full resync en vez de delta (DA-08).', false)
on conflict (clave) do nothing;
