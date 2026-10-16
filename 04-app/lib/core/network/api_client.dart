import 'package:dio/dio.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/core/network/dio_error_mapper.dart';

/// Cliente HTTP de la app sobre Dio.
///
/// Envuelve las llamadas y traduce errores a [Result]/[Failure] con
/// [DioErrorMapper], de modo que las capas superiores nunca atrapen
/// `DioException`. La configuración (base URL, interceptores) se arma en el
/// provider (`network_providers.dart`).
///
/// Pendiente de hardening [DA-14]: certificate pinning y verificación de
/// integridad del dataset se añaden sobre este cliente antes de producción.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// GET que devuelve el cuerpo decodificado o una [Failure].
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
      );
      return Ok(response.data as T);
    } catch (e) {
      return Err(DioErrorMapper.map(e));
    }
  }

  /// POST que devuelve el cuerpo decodificado o una [Failure].
  Future<Result<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return Ok(response.data as T);
    } catch (e) {
      return Err(DioErrorMapper.map(e));
    }
  }

  /// POST que devuelve el **status HTTP + cuerpo** sin mapear a [Failure] ni
  /// lanzar ante códigos de error. Útil cuando la lógica necesita distinguir
  /// casos por el cuerpo del error (p. ej. `device_revocado` vs `device_not_found`
  /// en `v1-session/refresh`). En error de transporte (sin respuesta), devuelve
  /// status `null`.
  Future<({int? status, dynamic body})> postRaw(
    String path, {
    Object? data,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        options: Options(validateStatus: (_) => true),
      );
      return (status: response.statusCode, body: response.data);
    } catch (e) {
      return (status: null, body: e);
    }
  }
}
