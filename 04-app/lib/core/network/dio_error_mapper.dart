import 'package:dio/dio.dart';
import 'package:shield_app/core/error/failure.dart';

/// Traduce errores de Dio a [Failure] de dominio.
///
/// Mantiene el mapeo de transporte → dominio en un solo lugar, para que
/// repositorios y casos de uso trabajen solo con [Failure]. Reconoce los
/// contratos de la API (`05-backend-api-metricas.md`): 401 device/sesión,
/// 426 upgrade requerido [DA-15].
abstract final class DioErrorMapper {
  static Failure map(Object error) {
    if (error is! DioException) {
      return UnknownFailure(message: '$error', cause: error);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkFailure(cause: error);
      case DioExceptionType.badResponse:
        return _mapResponse(error);
      case DioExceptionType.cancel:
        return NetworkFailure(message: 'Solicitud cancelada', cause: error);
      case DioExceptionType.badCertificate:
        return NetworkFailure(message: 'Certificado no válido', cause: error);
      case DioExceptionType.unknown:
      // Cubre también casos futuros del enum (p. ej. transformTimeout).
      // ignore: unreachable_switch_default
      default:
        return UnknownFailure(message: '$error', cause: error);
    }
  }

  static Failure _mapResponse(DioException error) {
    final response = error.response;
    final status = response?.statusCode;
    final data = response?.data;

    switch (status) {
      case 401:
        return AuthFailure(cause: error);
      case 426:
        final minVersion = data is Map && data['min_version'] is String
            ? data['min_version'] as String
            : 'desconocida';
        return UpgradeRequiredFailure(minVersion: minVersion, cause: error);
      default:
        final message = data is Map && data['error'] is String
            ? data['error'] as String
            : 'Error del servidor';
        return ServerFailure(message, statusCode: status, cause: error);
    }
  }
}
