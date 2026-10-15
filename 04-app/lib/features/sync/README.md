# features/sync

Delta sync del dataset de hashes, background e integridad. **Aún no
implementado** (scaffolding).

Responsabilidad futura ([DA-08], `03-architecture/04-app-flutter.md` §04.7):

- Orquesta: background diario (WorkManager Android), oportunista al abrir la app
  y al recuperar red.
- Verifica integridad (checksum/firma) antes de aplicar.
- Full resync si cambió `pepper_version` o el gap es grande.
- Actualiza `last_synced_version` y el `Set` en memoria para el matching.
