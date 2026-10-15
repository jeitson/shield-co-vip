# core/crypto

Primitivas criptográficas del cliente. **Aún no implementado** (scaffolding).

Responsabilidad futura ([DA-05], `03-architecture/02-seguridad-y-criptografia.md`):

- `HMAC-SHA-256(pepper, número_E164)` para el matching local de hashes.
- Verificación de checksum/firma del dataset descargado ([DA-14]).

El pepper nunca se persiste en la SQLite; vive en el keystore (`core/secure`).
