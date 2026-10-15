import 'package:shield_app/bootstrap.dart';
import 'package:shield_app/core/config/app_config.dart';

/// Entrypoint del flavor de producción.
///
/// Ejecutar/compilar con las credenciales reales de Supabase:
///   flutter build apk --flavor prod -t lib/main_prod.dart \
///     --dart-define-from-file=dart_defines.json
Future<void> main() => bootstrap(AppConfig.prod());
