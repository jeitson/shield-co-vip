# core/secure

Acceso al keystore del SO (Android Keystore / iOS Keychain) para custodiar
material sensible. Nunca en `SharedPreferences` plano ni en la SQLite.

Responsabilidad ([DA-05], [DA-07], [DA-14]):

- **DEK** de la base local cifrada (`LocalCryptoKeys`) — ✅ implementado en la
  spec [`03-persistencia-local`](../../../../.kiro/specs/03-persistencia-local/).
- **Tokens** de sesión (`features/auth/AuthSessionStore`, usa el mismo
  `secureStorageProvider`) — ✅ implementado en `01-autenticacion`.
- **Pepper** del dataset de hashes — ⏳ pendiente (`04-dataset-sync`): se guarda
  aquí tras entregarlo `v1-pepper`, nunca en la base.

## Contenido

- `secure_providers.dart` — `secureStorageProvider` (instancia compartida de
  `FlutterSecureStorage`) y `secureAndroidOptions` (respaldo Keystore).
- `local_crypto_keys.dart` — `LocalCryptoKeys`: `getOrCreateDek()` (256 bits
  aleatorios, independiente de la contraseña) y `deleteDek()` (wipe en revocación).

La DEK es independiente de la contraseña: un reset de clave por email no deja la
base ilegible (`02-seguridad` §02.3). Borrar la DEK vuelve la base ilegible y el
siguiente arranque genera una nueva base vacía.
