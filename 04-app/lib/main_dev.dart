import 'package:shield_app/bootstrap.dart';
import 'package:shield_app/core/config/app_config.dart';

/// Entrypoint del flavor de desarrollo.
///
/// Ejecutar con:
///   flutter run --flavor dev -t lib/main_dev.dart
Future<void> main() => bootstrap(AppConfig.dev());
