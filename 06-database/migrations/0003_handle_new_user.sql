-- 0003_handle_new_user.sql
-- Trigger de alta: crea el perfil al registrarse un usuario en auth.users.
--
-- Lee los metadatos que la app envía en el signUp (`raw_user_meta_data`):
-- nombre, apellido, celular (E.164) y los consentimientos. `security definer`
-- para insertar saltándose RLS durante el alta. Ref: 02-backend-database design §3.

create or replace function public.handle_new_user() returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (
    id, email, nombre, apellido, celular,
    terminos_aceptados, privacidad_aceptada
  )
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'nombre', ''),
    coalesce(new.raw_user_meta_data ->> 'apellido', ''),
    new.raw_user_meta_data ->> 'celular',
    coalesce((new.raw_user_meta_data ->> 'terminos_aceptados')::boolean, false),
    coalesce((new.raw_user_meta_data ->> 'privacidad_aceptada')::boolean, false)
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
