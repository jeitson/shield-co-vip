-- 0009_reports.sql
-- Reporte comunitario anónimo con moderación [DA-10] (spec 04-detalle-evento).
--
-- Un dispositivo reporta un número infractor a la comunidad. El reporte NO
-- entra directo a la blacklist global: queda en `pendiente` hasta superar un
-- umbral de N reportes independientes (dedup por device_id anónimo), lo que un
-- job de moderación (pg_cron, FUERA de alcance de esta spec) promovería a
-- `phone_hashes`. La escritura va por Edge Function (service role); el cliente
-- no escribe (RLS). El reporte es anónimo respecto al reportante: se guarda el
-- número legible del INFRACTOR (moderación/auditoría), nunca identidad del
-- denunciante. Ref: 03-datos §03.6; 05-backend §05.2; RN-02.
--
-- Incluye una tabla mínima de **números protegidos** (allowlist anti-
-- envenenamiento): bancos, emergencias y entidades que no deben poder caer en
-- la blacklist comunitaria. La Edge Function rechaza reportes contra ellos.

-- 1) Allowlist de protección -------------------------------------------------
create table if not exists public.protected_numbers (
  numero_e164 text primary key,         -- número protegido en E.164 (RN-04)
  etiqueta    text,                      -- descripción legible (banco, 123, etc.)
  created_at  timestamptz not null default now()
);

comment on table public.protected_numbers is
  'Allowlist anti-envenenamiento (DA-10): números legítimos que NO pueden entrar a la blacklist comunitaria. Solo lectura server-side.';

alter table public.protected_numbers enable row level security;
-- Sin policy para el cliente: solo la Edge Function (service role) la consulta.

-- Semilla mínima de números protegidos colombianos (líneas de emergencia /
-- ejemplos). Ampliable por operación. Idempotente.
insert into public.protected_numbers (numero_e164, etiqueta) values
  ('+57123',        'Línea de emergencia nacional (123)'),
  ('+57119',        'Policía Nacional (anti-secuestro/extorsión)'),
  ('+57165',        'Línea anticorrupción / fiscalía'),
  ('+5760134307000','Ejemplo entidad bancaria (línea oficial)')
on conflict (numero_e164) do nothing;

-- 2) Reportes comunitarios ---------------------------------------------------
create table if not exists public.reports (
  id             uuid primary key default gen_random_uuid(),
  -- HMAC-SHA256(pepper, numero_E164) en hex: mismo algoritmo que phone_hashes,
  -- para que al promover el hash coincida con el dataset.
  hash           text not null,
  -- Número legible del INFRACTOR, SOLO moderación/auditoría (nunca al device).
  numero_legible text not null,
  categoria      text not null,          -- catálogo RN-07 (label)
  -- Reportante anónimo: device_id de instalación (DA-02), NO PII de hardware ni
  -- user_id. Sirve exclusivamente para la dedup del umbral.
  device_id_anon uuid not null,
  pepper_version int  not null,          -- versión de pepper usada al hashear
  estado         text not null default 'pendiente'
                   check (estado in ('pendiente', 'promovido', 'rechazado')),
  created_at     timestamptz not null default now(),
  -- Dedup DA-10: un device cuenta UNA vez por número (y versión de pepper).
  unique (device_id_anon, hash, pepper_version)
);

comment on table public.reports is
  'Reportes comunitarios anónimos (DA-10). Entran en pendiente; un job de moderación los promueve a phone_hashes al superar el umbral (fuera de alcance de la spec 04). Anónimos respecto al reportante.';
comment on column public.reports.device_id_anon is
  'device_id de instalación del reportante (DA-02). Solo para dedup del umbral; no es PII de hardware ni user_id.';

-- Conteo de reportes independientes por número (para la futura promoción).
create index if not exists idx_reports_hash
  on public.reports (hash, pepper_version);

alter table public.reports enable row level security;
-- Sin policy de insert/update/delete/select para el cliente: solo la Edge
-- Function (service role) escribe/lee. (03-datos §03.2 [DA-11].)
