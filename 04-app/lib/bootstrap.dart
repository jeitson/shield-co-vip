import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/app.dart';
import 'package:shield_app/core/config/app_config.dart';
import 'package:shield_app/core/config/config_providers.dart';

/// Arranque compartido por todos los flavors.
///
/// Cada entrypoint (`main_dev.dart` / `main_prod.dart`) construye su
/// [AppConfig] y la pasa aquí. Centralizar el arranque evita duplicar la
/// inicialización de bindings, el `ProviderScope` y el override de config.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Punto único para inicializaciones tempranas que se agregarán al crecer
  // el proyecto (orientación, secure storage, DB cifrada, etc.). Mantener
  // esto fuera de los widgets conserva el dominio agnóstico.

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
      child: const ShieldApp(),
    ),
  );
}
