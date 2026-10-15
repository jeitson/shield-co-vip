import 'package:shield_app/bootstrap.dart';
import 'package:shield_app/core/config/app_config.dart';

/// Entrypoint del flavor de producción.
///
/// Ejecutar con:
///   flutter run --flavor prod -t lib/main_prod.dart
Future<void> main() => bootstrap(AppConfig.prod());
