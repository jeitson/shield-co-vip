import 'package:shield_app/main_dev.dart' as dev;

/// Entrypoint por defecto. Delega en el flavor de desarrollo para que
/// `flutter run` sin argumentos arranque en dev. Para builds explícitos use
/// `lib/main_dev.dart` o `lib/main_prod.dart` con `--flavor`.
Future<void> main() => dev.main();
