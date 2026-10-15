import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/config/config_providers.dart';
import 'package:shield_app/core/router/app_router.dart';
import 'package:shield_app/core/theme/app_theme.dart';

/// Widget raíz de la aplicación.
///
/// Cablea el router (go_router) y el tema oscuro único. Lee la [AppConfig]
/// activa para el título. Es un `ConsumerWidget` para acceder a los providers.
class ShieldApp extends ConsumerWidget {
  const ShieldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final config = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: config.environment.isDev,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
