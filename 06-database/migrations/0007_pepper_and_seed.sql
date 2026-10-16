-- 0007_pepper_and_seed.sql
-- Pepper en Vault + seed de ~300 firmas de prueba (Fase 3).
--
-- 1) Crea el PEPPER secreto en Supabase Vault (si no existe). Alta entropía
--    (32 bytes aleatorios en base64). El pepper NUNCA sale en claro por REST;
--    solo lo leen las Edge Functions (service role) desde vault.decrypted_secrets.
--    Ref: 02-seguridad §02.2 [DA-05].
-- 2) Siembra ~300 números colombianos INVENTADOS (+573XXXXXXXXX, RN-04),
--    repartidos por categoría/nivel (RN-07), con
--    hash = encode(hmac(numeroE164, pepper, 'sha256'), 'hex')  [pgcrypto].
--    El mismo algoritmo lo usa `v1-sync`/el dispositivo → el matching coincide.
--
-- Idempotente: si ya hay firmas sembradas, no duplica.

create extension if not exists pgcrypto with schema extensions;

-- 1) Pepper en Vault ---------------------------------------------------------
do $$
declare
  v_exists int;
begin
  select count(*) into v_exists
  from vault.secrets
  where name = 'dataset_pepper';

  if v_exists = 0 then
    perform vault.create_secret(
      encode(extensions.gen_random_bytes(32), 'base64'),
      'dataset_pepper',
      'Pepper HMAC del dataset de hashes (Fase 3). Rotar incrementa pepper_version.'
    );
  end if;
end $$;

-- 1b) RPC para leer el pepper desde las Edge Functions ----------------------
-- El esquema `vault` no se expone por PostgREST; las Edge Functions leen el
-- pepper vía esta RPC `security definer`. Se revoca a anon/authenticated y solo
-- el service role (Edge Functions) puede ejecutarla.
create or replace function public.get_dataset_pepper()
returns table (pepper text, pepper_version int)
language sql
security definer
set search_path = public, vault, extensions
as $$
  select
    (select decrypted_secret from vault.decrypted_secrets where name = 'dataset_pepper'),
    (select dv.pepper_version from public.dataset_version dv where dv.id = 1);
$$;

revoke all on function public.get_dataset_pepper() from public, anon, authenticated;
grant execute on function public.get_dataset_pepper() to service_role;

-- 2) Seed de firmas ----------------------------------------------------------
do $$
declare
  v_pepper text;
  v_count  int;
  i        int;
  v_num    text;
  v_cat    text;
  v_niv    text;
  v_bucket int;
begin
  -- Solo sembrar si la tabla está vacía (idempotencia).
  select count(*) into v_count from public.phone_hashes;
  if v_count > 0 then
    return;
  end if;

  select decrypted_secret into v_pepper
  from vault.decrypted_secrets
  where name = 'dataset_pepper';

  if v_pepper is null then
    raise exception 'No se encontró el pepper en Vault (dataset_pepper).';
  end if;

  -- 300 números: distribución RN-07.
  --   1..120  (40%) extorsión          → ALTO
  --   121..180 (20%) phishing/vishing  → ALTO/MEDIO (alterna)
  --   181..255 (25%) call center       → MEDIO
  --   256..300 (15%) Ley 2300          → BAJO
  for i in 1..300 loop
    -- Número CO inventado determinista: +573 + 9 dígitos derivados de i.
    v_num := '+573' || lpad((100000000 + i * 7)::text, 9, '0');

    if i <= 120 then
      v_cat := 'Extorsión / amenaza';
      v_niv := 'ALTO';
    elsif i <= 180 then
      v_cat := 'Phishing / vishing (suplantación)';
      v_niv := case when i % 2 = 0 then 'ALTO' else 'MEDIO' end;
    elsif i <= 255 then
      v_cat := 'Call center / discador robótico';
      v_niv := 'MEDIO';
    else
      v_cat := 'Violación franja Ley 2300';
      v_niv := 'BAJO';
    end if;

    insert into public.phone_hashes (
      hash, numero_legible, categoria, nivel,
      added_at_version, removed_at_version, pepper_version
    )
    values (
      encode(extensions.hmac(v_num, v_pepper, 'sha256'), 'hex'),
      v_num,
      v_cat,
      v_niv,
      1,            -- added_at_version: entran en la versión 1
      null,         -- activas
      1             -- pepper_version vigente
    )
    on conflict (hash, pepper_version) do nothing;
  end loop;

  -- Fijar el contador global: el dataset arranca en la versión 1.
  update public.dataset_version
  set current_version = 1,
      pepper_version = 1,
      updated_at = now()
  where id = 1;
end $$;
