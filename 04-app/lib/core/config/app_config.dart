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
    this.supabaseUrl = '',
    this.supabaseAnonKey = '',
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

  /// URL del proyecto Supabase (`https://<ref>.supabase.co`). Se inyecta por
  /// `--dart-define=SUPABASE_URL=...`; vacío cuando no está configurado (p. ej.
  /// tests o desarrollo offline → se usa la fuente de datos fake).
  final String supabaseUrl;

  /// Clave anónima pública de Supabase (segura en el cliente; RLS protege los
  /// datos). Se inyecta por `--dart-define=SUPABASE_ANON_KEY=...`.
  final String supabaseAnonKey;

  /// `true` cuando hay credenciales de Supabase para operar contra el backend
  /// real. Si es `false`, la app cae a la fuente de datos fake de desarrollo.
  bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Credenciales de Supabase leídas del entorno de compilación
  /// (`--dart-define` / `--dart-define-from-file`). Sin valores por defecto:
  /// los secretos no se hardcodean en el repo.
  static const _envSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _envSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Config de desarrollo. Apunta al entorno dev/staging.
  factory AppConfig.dev() => const AppConfig(
    environment: AppEnvironment.dev,
    appName: 'Cifrado Cero DEV',
    // Placeholder: reemplazar por la URL real del proyecto Supabase dev.
    apiBaseUrl: 'https://dev.cifradocero.example.com/functions',
    apiVersion: 'v1',
    enableLogging: true,
    supabaseUrl: _envSupabaseUrl,
    supabaseAnonKey: _envSupabaseAnonKey,
  );

  /// Config de producción.
  factory AppConfig.prod() => const AppConfig(
    environment: AppEnvironment.prod,
    appName: 'Cifrado Cero',
    // Placeholder: reemplazar por la URL real del proyecto Supabase prod.
    apiBaseUrl: 'https://api.cifradocero.example.com/functions',
    apiVersion: 'v1',
    enableLogging: false,
    supabaseUrl: _envSupabaseUrl,
    supabaseAnonKey: _envSupabaseAnonKey,
  );

  /// Base de las Edge Functions de Supabase (`<proyecto>.supabase.co/functions/v1`).
  ///
  /// Cuando hay credenciales de Supabase, se deriva de [supabaseUrl] para
  /// apuntar a la URL real de publicación de funciones; si no, cae a
  /// [apiBaseUrl] (placeholder/local). Evita hardcodear la URL del proyecto.
  String get functionsBaseUrl =>
      hasSupabase ? '$supabaseUrl/functions' : apiBaseUrl;

  /// Base completa de la API de funciones, incluyendo el prefijo de versión.
  /// Ej: `https://<ref>.supabase.co/functions/v1`.
  String get versionedApiBaseUrl => '$functionsBaseUrl/$apiVersion';
}
