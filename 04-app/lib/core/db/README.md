# core/db

Persistencia local cifrada. **Aún no implementado** (scaffolding).

Responsabilidad futura ([DA-07], `03-architecture/04-app-flutter.md` §04.4):

- `drift` + SQLCipher (AES-256) con la DEK del keystore.
- Migraciones versionadas.
- Tablas: hashes descargados, listas locales, config del escudo, historial de
  eventos, contadores de métricas.

Para el volumen esperado (miles de hashes) la lista cabe en memoria como `Set`
para matching O(1); la SQLite es la persistencia, el `Set` el índice de runtime.
