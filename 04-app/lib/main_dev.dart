import 'package:shield_app/bootstrap.dart';
import 'package:shield_app/core/config/app_config.dart';

/// Entrypoint del flavor de desarrollo.
///
/// Ejecutar con (sin backend → usa la fuente de datos fake):
///   flutter run --flavor dev -t lib/main_dev.dart
///
/// Con backend real (Supabase), pasando las credenciales por archivo:
///   flutter run --flavor dev -t lib/main_dev.dart \
///     --dart-define-from-file=dart_defines.json
/// (copia `dart_defines.example.json` → `dart_defines.json` y rellena).
Future<void> main() => bootstrap(AppConfig.dev());
