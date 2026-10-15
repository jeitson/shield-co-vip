-- 0002_profiles_rls.sql
-- Row Level Security de `profiles` (Fase 1 · Auth MVP).
--
-- Cada usuario autenticado solo puede ver y actualizar SU propia fila. No hay
-- policy de insert/delete para el cliente: el alta la crea el trigger
-- `handle_new_user` (security definer) y el borrado se propaga por el cascade
-- de auth.users. Ref: 03-architecture/03-datos-y-sincronizacion.md §03.2 [DA-11].

alter table public.profiles enable row level security;

-- Lectura: solo el propio perfil.
drop policy if exists "perfil_propio_select" on public.profiles;
create policy "perfil_propio_select" on public.profiles
  for select
  using (auth.uid() = id);

-- Actualización: solo el propio perfil (y la fila resultante sigue siendo propia).
-- Nota: `email` lo gobierna Supabase Auth; la app no debe mutarlo aquí.
drop policy if exists "perfil_propio_update" on public.profiles;
create policy "perfil_propio_update" on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);
