# Spec · 01 Autenticación — Plan de implementación

> Estado al cierre de la iteración de UI/dominio. El backend real (Supabase) se
> construye en la spec `02-backend-database/`; aquí se marca qué queda cableado
> contra el fake de desarrollo y qué se migra al backend real.

- [x] 1. Dependencias y base
  - [x] 1.1 Añadir `flutter_secure_storage` a `pubspec.yaml` y resolver (`flutter pub get`).
  - _Req: R3.1, DA-14_

- [x] 2. Dominio (`features/auth/domain`)
  - [x] 2.1 Value objects `Email`, `Password`, `ColombianPhone` con validación y canonización E.164.
  - [x] 2.2 Entidades `UserAccount` y `AuthSession` (con `isExpired`).
  - [x] 2.3 Interfaz `AuthRepository` + `RegisterData`.
  - [x] 2.4 Casos de uso `Login`, `Register`, `Logout`, `RestoreSession`, `RequestPasswordReset`.
  - _Req: R1, R2, R3_

- [x] 3. Datos (`features/auth/data`)
  - [x] 3.1 DTOs `AuthSessionDto`, `UserAccountDto` (↔ entidad).
  - [x] 3.2 `AuthSessionStore` sobre secure storage.
  - [x] 3.3 `AuthRemoteDataSource` (contrato) + `AuthRemoteDataSourceFake` (dev, sin pre-relleno en UI).
  - [x] 3.4 `AuthRepositoryImpl` componiendo remoto + store + stream de sesión.
  - _Req: R1, R2, R3; RN-LOGIN-02_

- [x] 4. Presentación — fundamentos (`features/auth/presentation`)
  - [x] 4.1 Providers de DI (data source, store, repo, casos de uso) y `authStatusProvider` real desde `watchSession()`.
  - [x] 4.2 Form states + Notifiers (login/register) y submit controllers (`AsyncNotifier`).
  - _Req: R1, R2, R3_

- [x] 5. Presentación — widgets compartidos
  - [x] 5.1 `AuthScaffold`, `BrandHeader`, `AuthTextField`, `ConsentCheckbox`.
  - _Req: R4_

- [x] 6. Pantallas
  - [x] 6.1 `LoginScreen` fiel al prototipo (toggle clave, consentimientos, estados, enlaces).
  - [x] 6.2 `RegisterScreen` fiel (banner, campos, +57 fijo, estados idle/enviando/hecho).
  - _Req: R1, R2, R4_

- [x] 7. Router / arranque
  - [x] 7.1 `initialLocation` en splash → login/escudo según guard; manejar estado `unknown`.
  - _Req: R3_

- [x] 8. Verificación (iteración UI/dominio)
  - [x] 8.1 Pruebas unitarias de VOs y casos de uso.
  - [x] 8.2 `flutter analyze` sin errores y `dart format`.
  - _Req: todos_

---

## 9. Backend real (continúa en spec `02-backend-database/`)

Lo construido arriba funciona hoy contra `AuthRemoteDataSourceFake` (en memoria).
Para producción, estas tareas migran el flujo a Supabase real; **dominio,
presentación y pruebas no cambian** (solo se sustituye la fuente remota).

- [x] 9.1 Implementar `AuthRemoteDataSourceSupabase` (Supabase Auth: signUp / signInWithPassword / resetPasswordForEmail) y mapear a los DTOs existentes.
  - _Req: RF-LOGIN-04, RF-REG-08; DN-01, DA-11_
- [x] 9.2 Sustituir `authRemoteDataSourceProvider` por la impl real según entorno; dejar el fake como fallback de desarrollo.
- [x] 9.3 Persistir/actualizar `profiles` en el alta (trigger de DB + metadatos del signUp).
  - _Req: R2; esquema en `02-backend-database`_
- [x] 9.4 Recuperación de clave real por email vía Supabase Auth (reemplaza el diálogo informativo).
  - _Req: RF-LOGIN-05; DA-04_
- [x] 9.5 Backend desplegado y login validado contra el proyecto Supabase real (signUp pobló `profiles` vía trigger; signInWithPassword devolvió `access_token`). `04-app/dart_defines.json` apunta a la URL/anon key reales. Pendiente solo la prueba visual en dispositivo/emulador.
  - _Req: CA-LOGIN-02_

> **Nota de flujo:** el refresh de sesión 12h contra `devices`, el OTP de celular
> y el registro de dispositivo (DA-03/DA-04) pertenecen a los flujos de shell/
> onboarding y a `02-backend-database`, no a estas dos pantallas.

---

## 10. Confirmación de correo obligatoria (R7)

- [x] 10.1 Caso de uso `ResendConfirmation` + método `resendConfirmation(email)` en `AuthRemoteDataSource` (Supabase `auth.resend`) y en el fake.
- [x] 10.2 `Failure` específico `EmailNotConfirmedFailure` y mapeo del error de Supabase ("email not confirmed") en el login. (También `EmailConfirmationPendingFailure` para el alta en dos pasos, RN-REG-05.)
- [x] 10.3 En login: detectar cuenta no confirmada y ofrecer acción **"Reenviar correo de confirmación"** con aviso neutro. (Registro muestra `pendingConfirmation` en verde y redirige a login.)
- [x] 10.4 Verificación automatizada: `flutter analyze` sin issues y `flutter test` (114 passed, incluye `ResendConfirmation`). **Pendiente** la prueba en dispositivo real (registro → login bloqueado → reenviar) con la confirmación activa en el panel.
- [x] 10.5 Plantilla de correo (es-CO, marca Cifrado Cero) en `05-backend/email-templates/confirm-signup.html` + `README.md` con el paso a paso para pegarla en el panel de Supabase.
  - _Req: R7 (RN-LOGIN-04, RN-REG-05)_
