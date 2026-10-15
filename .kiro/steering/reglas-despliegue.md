---
inclusion: always
---

# Reglas de despliegue — INVIOLABLES

## R-DEPLOY-01 · Nunca desplegar a Supabase sin confirmación explícita del usuario

**Prohibido** ejecutar cualquier operación que modifique o publique en el proyecto
Supabase remoto **sin que el usuario lo confirme explícitamente en el turno actual**.

Esto incluye, sin limitarse a:
- `supabase db push` (aplicar migraciones a la base remota).
- `supabase functions deploy` (publicar Edge Functions).
- `supabase db reset` / `db execute` contra remoto, o cualquier SQL de escritura (INSERT/UPDATE/DELETE/DDL) vía REST, Admin API o conexión directa a la base de producción.
- Crear/editar/borrar usuarios de Auth, cambiar configuración del proyecto, secretos o Vault en remoto.
- Cualquier `supabase link` o acción que use el `SUPABASE_ACCESS_TOKEN`/`service_role` para mutar el proyecto remoto.

**Sí está permitido sin confirmación** (solo lectura / local):
- Leer/consultar datos para verificar (SELECT por REST, `--dry-run`).
- Editar archivos locales (migraciones, funciones, config, `.env` de ejemplo).
- Correr la app, `flutter analyze`, tests.

**Procedimiento obligatorio antes de desplegar:**
1. Explicar qué se va a desplegar y el impacto (qué cambia, si es reversible).
2. **Esperar un "sí/confirmo/adelante" explícito del usuario para esa acción concreta.**
3. Solo entonces ejecutar. Una confirmación aplica a esa acción puntual, no a futuras.

Ante la duda, **no desplegar y preguntar**.
