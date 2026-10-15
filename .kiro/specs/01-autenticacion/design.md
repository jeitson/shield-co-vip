# Spec · 01 Autenticación — Diseño

> Diseño técnico de la feature `auth` en la app Flutter (`04-app`).
> Alineado a Clean Architecture por features [DA-13], Riverpod y los tokens de `core/theme`.

---

## 1. Panorama

```
features/auth/
├── domain/
│   ├── entities/
│   │   ├── auth_session.dart        # tokens + expiración (12h, DA-04)
│   │   └── user_account.dart        # Usuario del dominio (00-fundamentos)
│   ├── value_objects/
│   │   ├── email.dart               # validación de correo
│   │   ├── password.dart            # política ≥ 8 (RN-REG-02)
│   │   └── colombian_phone.dart     # móvil CO: 10 dígitos, inicia en 3 (RN-REG-04)
│   ├── repositories/
│   │   └── auth_repository.dart     # interfaz (contrato puro)
│   └── usecases/
│       ├── login.dart
│       ├── register.dart
│       ├── logout.dart
│       ├── restore_session.dart
│       └── request_password_reset.dart
├── data/
│   ├── dtos/
│   │   ├── auth_session_dto.dart
│   │   └── user_account_dto.dart
│   ├── datasources/
│   │   ├── auth_remote_data_source.dart       # contrato remoto
│   │   ├── auth_remote_data_source_fake.dart  # impl MVP sin backend real
│   │   └── auth_session_store.dart            # secure storage de sesión
│   └── repositories/
│       └── auth_repository_impl.dart
└── presentation/
    ├── auth_providers.dart          # providers de DI + authStatusProvider (real)
    ├── controllers/
    │   ├── login_controller.dart    # AsyncNotifier del submit de login
    │   └── register_controller.dart # AsyncNotifier del submit de registro
    ├── state/
    │   ├── login_form_state.dart
    │   └── register_form_state.dart
    ├── login_screen.dart
    ├── register_screen.dart
    └── widgets/
        ├── auth_scaffold.dart       # fondo + scrim + layout común
        ├── auth_text_field.dart     # input con icono-afijo del design system
        ├── consent_checkbox.dart
        └── brand_header.dart
```

Regla de dependencia: `presentation → domain ← data`. El dominio no importa Flutter, Dio ni storage.

---

## 2. Dominio

### Entidades

- **`UserAccount`**: `id`, `correo`, `nombre`, `apellido`, `celular` (E.164), `terminosAceptados`, `privacidadAceptada`. Espeja `Usuario` de `00-fundamentos`.
- **`AuthSession`**: `accessToken`, `refreshToken`, `expiresAt`, `user`. `isExpired` deriva de `expiresAt` (ventana 12h, DA-04). Material sensible; nunca se loguea.

### Value Objects (validación centralizada)

Cada VO encapsula su validación y devuelve `Result<T>` o un `ValidationError` tipado para que la UI muestre mensajes consistentes y el dominio no dependa de regex dispersas:

- **`Email`**: formato válido (RFC básico, sin TLD exótico), normaliza a minúsculas.
- **`Password`**: longitud ≥ 8 (RN-REG-02). Preparado para endurecer (mayúscula/número/símbolo) sin cambiar el contrato — pregunta abierta del memory bank §2.
- **`ColombianPhone`**: exactamente 10 dígitos, inicia en `3`; canoniza a E.164 `+57XXXXXXXXXX` (RN-04 / RN-REG-04). El prefijo +57 es responsabilidad del VO, no de la UI.

### Interfaz de repositorio

```dart
abstract interface class AuthRepository {
  Future<Result<AuthSession>> login({required String identifier, required String password});
  Future<Result<AuthSession>> register(RegisterData data);
  Future<Result<void>> logout();
  Future<Result<AuthSession?>> restoreSession();     // null = sin sesión
  Future<Result<void>> requestPasswordReset(String email);
  Stream<AuthSession?> watchSession();               // alimenta authStatusProvider
}
```

### Casos de uso

Thin wrappers que orquestan validación + repositorio. Mantienen la presentación libre de reglas:

- `Login` — valida identificador/clave no vacíos → `repo.login`.
- `Register` — construye y valida los VOs → `repo.register`.
- `Logout`, `RestoreSession`, `RequestPasswordReset`.

---

## 3. Datos

### Contrato remoto y estrategia MVP

El backend Supabase todavía no tiene entorno real (URLs placeholder en `AppConfig`). Para no bloquear el flujo y mantener la frontera limpia:

- `AuthRemoteDataSource` define el contrato (login/register/reset) devolviendo DTOs.
- `AuthRemoteDataSourceFake` lo implementa **en memoria** para el MVP: valida credenciales contra un store local sembrado, simula latencia realista y produce errores de dominio (credenciales inválidas, correo duplicado, red). **No pre-rellena credenciales en la UI** (RN-LOGIN-02); el seed vive solo en la capa de datos para poder probar el camino feliz.
- Cuando exista el backend, se añade `AuthRemoteDataSourceSupabase` (Dio sobre `ApiClient`, contratos `/v1` de `05-backend-api-metricas`) y se cambia **un solo provider**. La UI y el dominio no cambian.

> Esto respeta "fallar hacia la privacidad" y la frontera de la Edge Function: el cliente nunca toca el pepper ni tablas; aquí solo se modela auth de cuenta.

### Almacenamiento de sesión

- `AuthSessionStore` persiste `AuthSession` en **secure storage** (`flutter_secure_storage`, respaldado por Android Keystore / iOS Keychain) — nunca en SharedPreferences plano (DA-14, `02-seguridad` §02.3). Tokens fuera de la SQLite.
- En arranque, `restoreSession()` lee el store; si el token expiró, intenta refrescar (contrato futuro `/v1/session/refresh`); en el MVP fake, se considera válido mientras `!isExpired`.

### Repositorio impl

`AuthRepositoryImpl` compone data source + session store, mapea DTO↔entidad y emite por un `StreamController<AuthSession?>` que alimenta el guard.

---

## 4. Presentación

### Gestión de estado

- **Form state** (`LoginFormState`, `RegisterFormState`): objetos inmutables con los campos, flags de consentimiento, visibilidad de clave y errores por campo. Gestionados con un `Notifier` por pantalla.
- **Submit controllers** (`LoginController`, `RegisterController`): `AsyncNotifier<void>` que exponen `AsyncValue` para los estados cargando/éxito/error (los 4 estados del dominio, §00.5). La UI escucha y pinta el botón ("Descifrando Enclave…", "Blindando Identidad…"/"Identidad Generada") y los errores.
- **`authStatusProvider`**: se reimplementa para derivar de `watchSession()` del repositorio, con un estado `unknown` real mientras se restaura (R3.3). El router ya lo consume.

### Pantallas (fidelidad al prototipo)

Reutilizan widgets compartidos para no duplicar estilos:

- `AuthScaffold`: fondo con gradiente/scrim oscuro, `SafeArea`, scroll, ancho máx ~420 (móvil-first, §6.1).
- `BrandHeader`: icono en contenedor redondeado + título Space Grotesk + subtítulo.
- `AuthTextField`: input con icono-afijo, label mono en mayúsculas, foco cyan, error inline; toggle de visibilidad para claves.
- `ConsentCheckbox`: checkbox + texto, con semántica accesible.
- **Login**: identificador, clave (toggle), "¿Olvidaste tu clave?", 2 consentimientos, botón primario con estados, enlace a registro.
- **Register**: banner "Garantía Absoluta", nombre+apellido (fila), correo, contraseña (toggle + hint "Mín. 8"), celular con prefijo +57 bloqueado, 2 consentimientos, botón con estados (idle/enviando/hecho), enlace a login.

### Mapa de estados → UI

| Estado | Login | Register |
|--------|-------|----------|
| Inicial | formulario vacío, botón según consentimientos | igual |
| Enviando | spinner + "Descifrando Enclave…", campos bloqueados | "Blindando Identidad…" |
| Éxito | navega al Dashboard | "Identidad Generada" → Dashboard |
| Error | SnackBar/inline + campos editables | marca campo o error de servidor |

---

## 5. Navegación / guard

- Arranque en `/login` cuando `authStatusProvider == unauthenticated` (ya implementado en `app_router.dart`).
- `initialLocation` del router pasa a `loginPath` (hoy es `shieldPath`); el guard igual corrige, pero el arranque explícito evita un redirect innecesario.
- `unknown` mientras se restaura sesión → el router no redirige (ya contemplado); se añade una pantalla/estado de carga breve.

---

## 6. Dependencias nuevas

- `flutter_secure_storage` para tokens de sesión (DA-14). Única dependencia nueva requerida.

---

## 7. Pruebas

- **Unitarias de VOs**: `Email`, `Password`, `ColombianPhone` (casos válidos/ inválidos, canonización E.164).
- **Casos de uso**: `Login`/`Register` con un `AuthRepository` falso (éxito, credenciales inválidas, duplicado, red).
- **Widget (humo)**: el botón de login permanece deshabilitado sin consentimientos (CA-LOGIN-01) y el toggle de visibilidad funciona (CA-LOGIN-04).
