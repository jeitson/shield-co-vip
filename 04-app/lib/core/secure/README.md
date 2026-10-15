# core/secure

Acceso al keystore del SO (Android Keystore / iOS Keychain). **Aún no
implementado** (scaffolding).

Responsabilidad futura ([DA-05], [DA-07], [DA-14]):

- Custodiar el **pepper**, la **DEK** de SQLCipher y los **tokens** de sesión.
- Respaldado por hardware (TEE/Secure Enclave).
- Borrado de material sensible al revocarse el dispositivo (refresh falla, [DA-04]).
