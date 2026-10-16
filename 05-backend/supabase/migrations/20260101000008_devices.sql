-- 0008_devices.sql
-- Dispositivos por cuenta (Fase 2 · gestión de sesión y exclusividad).
--
-- Cada cuenta puede tener varios dispositivos (RN-DEV-01), pero un
-- `numero_protegido` solo puede estar ACTIVO en uno a la vez (RN-DEV-02, DA-03).
-- El `id` es el UUID de instalación propio del dispositivo [DA-02], NO PII de
-- hardware. La escritura va por Edge Function (service role); el cliente solo
-- lee sus propios dispositivos (RLS). Ref: 03-datos §03.1/§03.2; DA-02/03/04.

create table if not exists public.devices (
  id                  uuid primary key,                 -- device_id de instalación
  profile_id          uuid not null references public.profiles (id) on delete cascade,
  marca               text,
  modelo              text,
  so                  text,
  so_version          text,
  app_version         text,
  idioma              text,
  zona_horaria        text,
  estado              text not null default 'activo'
                        check (estado in ('activo', 'revocado')),
  numero_protegido    text,
  last_synced_version int  not null default 0,
  last_seen_at        timestamptz,
  created_at          timestamptz not null default now()
);

comment on table public.devices is
  'Dispositivos de la cuenta. id = UUID de instalación propio (DA-02). Un numero_protegido solo puede estar activo en un device a la vez (DA-03). estado gobierna la revocación (DA-04).';
comment on column public.devices.numero_protegido is
  'Celular que blinda este dispositivo (= profiles.celular en el MVP).';

-- Exclusividad por número: acelera "¿quién tiene este número activo?".
create index if not exists idx_devices_numero_activo
  on public.devices (numero_protegido)
  where estado = 'activo';

create index if not exists idx_devices_profile
  on public.devices (profile_id);

alter table public.devices enable row level security;

-- Lectura: solo los dispositivos del propio usuario. Escritura: solo Edge
-- Function (service role, sin policy para el cliente). (03-datos §03.2 [DA-11].)
drop policy if exists "devices_propios_select" on public.devices;
create policy "devices_propios_select" on public.devices
  for select
  using (auth.uid() = profile_id);
