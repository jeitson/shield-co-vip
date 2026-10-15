import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/config/config_providers.dart';
import 'package:shield_app/core/network/api_client.dart';
import 'package:shield_app/core/network/app_version_interceptor.dart';

/// Versión de la app enviada al backend para la política de actualización
/// forzada [DA-15]. Mantener sincronizada con `version` en `pubspec.yaml`.
/// A futuro leer con `package_info_plus` para evitar duplicar el valor.
const kAppVersion = '1.0.0';

/// Instancia configurada de Dio apuntando a la API versionada del entorno.
final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.versionedApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(AppVersionInterceptor(kAppVersion));

  if (config.enableLogging) {
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  return dio;
});

/// Cliente HTTP de alto nivel que devuelve [Result]/[Failure].
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
);
