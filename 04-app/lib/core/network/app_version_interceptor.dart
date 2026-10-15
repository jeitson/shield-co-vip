import 'package:dio/dio.dart';

/// Adjunta la versión de la app a cada request.
///
/// El backend compara `app_version` contra `min_app_version` para forzar
/// actualización de versiones obsoletas (responde 426) [DA-15]
/// (`05-backend-api-metricas.md`). Se envía como header para no acoplar el
/// cuerpo de cada endpoint.
class AppVersionInterceptor extends Interceptor {
  AppVersionInterceptor(this.appVersion);

  final String appVersion;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-App-Version'] = appVersion;
    handler.next(options);
  }
}
