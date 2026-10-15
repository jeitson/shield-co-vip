import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/config/app_config.dart';

/// Expone la [AppConfig] activa a todo el árbol de providers.
///
/// No tiene valor por defecto a propósito: cada entrypoint
/// (`main_dev` / `main_prod`) debe sobrescribirlo con `overrideWithValue`
/// al construir el `ProviderScope`. Esto evita acoplar el core a un entorno
/// concreto y hace el arranque explícito.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError(
    'appConfigProvider debe sobrescribirse en el entrypoint '
    '(main_dev.dart / main_prod.dart) con overrideWithValue.',
  );
});
