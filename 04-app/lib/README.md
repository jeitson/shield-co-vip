# Estructura y convenciones — App Flutter (Cifrado Cero)

Scaffolding de la app. Clean Architecture por features con Riverpod, alineado a
`03-architecture/04-app-flutter.md`. **No contiene lógica de negocio todavía**:
las pantallas son placeholders y varias carpetas solo documentan su propósito.

## Capas (regla de dependencia hacia el dominio)

```
presentation  →  domain  ←  data
```

- **presentation**: widgets + providers Riverpod. Habla solo con casos de uso.
- **domain**: Dart puro (sin Flutter/Supabase/SQLite). Entidades, casos de uso,
  interfaces de repositorio, motor de precedencia de 5 niveles.
- **data**: implementa las interfaces del dominio con tecnologías concretas
  (Dio, drift+SQLCipher, keystore, BlockingEngine nativo).

## Árbol

```
lib/
├── core/                  # Infraestructura transversal, agnóstica de feature
│   ├── config/            # AppConfig, flavors (dev/prod), providers de config
│   ├── crypto/            # HMAC + checksum (pendiente)
│   ├── db/                # drift + SQLCipher (pendiente)
│   ├── error/             # Failure + Result
│   ├── network/           # Dio, interceptores /v1, mapeo de errores
│   ├── platform/          # BlockingEngine (interfaz nativa, iOS-ready)
│   ├── router/            # go_router: rutas + guard de auth
│   ├── secure/            # keystore (pepper, DEK, tokens) (pendiente)
│   ├── theme/             # tokens de diseño + ThemeData oscuro
│   └── widgets/           # widgets compartidos (AsyncValueView, estados)
├── features/              # Una carpeta por capacidad de negocio (02-business)
│   ├── auth/              # 01-autenticacion
│   ├── shield/            # 02-escudo-dashboard
│   ├── events/            # 03-registro / 04-detalle
│   ├── settings/          # 05-listas-y-configuracion
│   ├── reports/           # 06-canales-denuncia
│   ├── simulator/         # 07-simulador
│   ├── sync/              # delta sync (pendiente)
│   └── metrics/           # métricas plano A/B (pendiente)
├── shell/                 # 08-navegacion-y-shell (bottom nav)
├── app.dart               # Widget raíz (MaterialApp.router + tema)
├── bootstrap.dart         # Arranque compartido (ProviderScope)
├── main.dart              # Entry por defecto → dev
├── main_dev.dart          # Entry flavor dev
└── main_prod.dart         # Entry flavor prod
```

Cada feature usa subcarpetas `presentation/`, `domain/`, `data/` según crezca.
Hoy la mayoría solo tiene `presentation/` con placeholders.

## Convenciones

- **Estado**: Riverpod. Los 4 estados del dominio (cargando/éxito/error/vacío)
  se modelan con `AsyncValue` y se renderizan con `AsyncValueView`.
- **Errores**: la capa data traduce excepciones a `Failure`; casos de uso y
  repositorios devuelven `Result<T>` (nunca lanzan hacia presentation).
- **Colores/tipografía/forma**: usar siempre tokens de `core/theme`
  (`AppColors`, `AppTypography`, `AppRadii`, `AppSpacing`). Nada hardcodeado.
- **Severidad**: `ThreatLevel` (color + label), nunca solo color (accesibilidad).
- **Navegación**: go_router con rutas nombradas en `AppRoutes`. Pila real,
  deep-link capable, con guard de auth (DN-02).
- **Entornos**: `AppConfig` resuelta por entrypoint; no leer flavors fuera de
  `core/config`.

## Flavors

```bash
flutter run   --flavor dev  -t lib/main_dev.dart
flutter run   --flavor prod -t lib/main_prod.dart
flutter build apk --flavor prod -t lib/main_prod.dart
```

## iOS (fase futura)

El núcleo (dominio, datos, UI, sync, métricas) es compartido y agnóstico. Solo
la interceptación cambia: Android usa `CallScreeningService` + rol SMS; iOS
usará Call Directory + Message Filter (modo lista), detrás de `BlockingEngine`.
No habrá paridad de interceptación, sí en todo lo demás ([DA-12]).
