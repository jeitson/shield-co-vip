import 'package:shield_app/core/config/app_environment.dart';

/// Configuración inmutable resuelta por entorno al arrancar la app.
///
/// Se inyecta una única instancia desde el entrypoint (`main_dev` / `main_prod`)
/// y se expone al árbol de widgets vía Riverpod (`appConfigProvider`). Mantener
/// aquí todo lo "configurable sin desplegar a nivel de build" (base URL de la
/// API, versión del prefijo de API, flags de depuración). Los parámetros de
/// negocio ajustables en caliente viven en el servidor (`app_params`),
/// no aquí (ver `05-backend-api-metricas.md` §05.5).
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.apiVersion,
    required this.enableLogging,
  });

  /// Entorno activo.
  final AppEnvironment environment;

  /// Nombre visible de la app (incluye sufijo DEV cuando aplica).
  final String appName;

  /// URL base del backend (Edge Functions de Supabase).
  final String apiBaseUrl;

  /// Prefijo de versión de la API [DA-15]. La API versiona por carpeta `/v1`.
  final String apiVersion;

  /// Habilita logging detallado de red y errores. Apagado en prod.
  final bool enableLogging;

  /// Config de desarrollo. Apunta al entorno dev/staging.
  factory AppConfig.dev() => const AppConfig(
        environment: AppEnvironment.dev,
        appName: 'Cifrado Cero DEV',
        // Placeholder: reemplazar por la URL real del proyecto Supabase dev.
        apiBaseUrl: 'https://dev.cifradocero.example.com/functions',
        apiVersion: 'v1',
        enableLogging: true,
      );

  /// Config de producción.
  factory AppConfig.prod() => const AppConfig(
        environment: AppEnvironment.prod,
        appName: 'Cifrado Cero',
        // Placeholder: reemplazar por la URL real del proyecto Supabase prod.
        apiBaseUrl: 'https://api.cifradocero.example.com/functions',
        apiVersion: 'v1',
        enableLogging: false,
      );

  /// Base completa de la API, incluyendo el prefijo de versión. Ej:
  /// `https://.../functions/v1`.
  String get versionedApiBaseUrl => '$apiBaseUrl/$apiVersion';
}
