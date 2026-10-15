-- 0001_profiles.sql
-- Tabla de perfiles de usuario (Fase 1 · Auth MVP).
--
-- Extiende `auth.users` (Supabase Auth es la fuente de identidad). Relación 1:1
-- con el usuario de Auth. El `celular` se guarda legible en E.164 (+57...),
-- necesario para la cuenta, la exclusividad por número y el OTP futuro.
-- Ref: 03-architecture/03-datos-y-sincronizacion.md §03.1; 02-business/00-fundamentos.

create table if not exists public.profiles (
  id                   uuid primary key references auth.users (id) on delete cascade,
  email                text not null,
  nombre               text not null default '',
  apellido             text not null default '',
  celular              text,
  terminos_aceptados   boolean not null default false,
  privacidad_aceptada  boolean not null default false,
  -- Telemetría poblacional es opt-in explícito (DA-01 / Ley 1581 Habeas Data).
  telemetria_optin     boolean not null default false,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

comment on table public.profiles is
  'Perfil de dominio 1:1 con auth.users. Identidad de cuenta (el servidor sí la conoce), distinta de los datos de terceros que nunca salen del dispositivo.';
comment on column public.profiles.celular is 'Celular propio en E.164 legible (+57XXXXXXXXXX).';
comment on column public.profiles.telemetria_optin is 'Opt-in explícito de métricas agregadas (DA-01).';

-- Mantener updated_at al día en cada cambio.
create or replace function public.set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();
