# features/metrics

Métricas en dos planos. **Aún no implementado** (scaffolding).

Responsabilidad futura ([DA-01], `03-architecture/05-backend-api-metricas.md`):

- **Plano B (local):** contadores en SQLite; "tu tiempo ahorrado" con constantes
  de `app_params`. Nunca sale del dispositivo.
- **Plano A (agregado, opt-in):** lotes diarios a `v1-metrics` (tipo/categoría/
  nivel/día/región gruesa). Nunca número, contenido, `user_id` ni `device_id`.
