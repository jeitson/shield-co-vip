import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/app.dart';
import 'package:shield_app/core/config/app_config.dart';
import 'package:shield_app/core/config/config_providers.dart';
import 'package:shield_app/features/sync/background/sync_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Arranque compartido por todos los flavors.
///
/// Cada entrypoint (`main_dev.dart` / `main_prod.dart`) construye su
/// [AppConfig] y la pasa aquí. Centralizar el arranque evita duplicar la
/// inicialización de bindings, el `ProviderScope` y el override de config.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase solo si hay credenciales (vía --dart-define). Sin
  // ellas (tests / desarrollo offline), la app opera con la fuente de datos
  // fake y no se inicializa el SDK. El anon key es público; RLS protege.
  if (config.hasSupabase) {
    await Supabase.initialize(
      url: config.supabaseUrl,
      // Clave pública publicable (antes `anonKey`); segura en cliente, RLS protege.
      publishableKey: config.supabaseAnonKey,
      debug: config.enableLogging,
    );

    // Sync periódico en background (Android MVP; iOS diferido). Solo con backend.
    if (Platform.isAndroid) {
      try {
        await registerBackgroundSync();
      } catch (_) {
        // No bloquear el arranque si WorkManager no está disponible.
      }
    }
  }

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const ShieldApp(),
    ),
  );
}
