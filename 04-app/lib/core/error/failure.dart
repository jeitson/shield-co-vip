import 'package:equatable/equatable.dart';

/// Error de dominio normalizado.
///
/// La capa de datos traduce excepciones de infraestructura (Dio, drift,
/// plataforma) a una [Failure] para que dominio y presentación no dependan de
/// detalles de transporte (`04-app-flutter` §04.1, carpeta `core/error`).
sealed class Failure extends Equatable {
  const Failure(this.message, {this.cause});

  /// Mensaje apto para mostrar o registrar.
  final String message;

  /// Causa original (excepción/objeto) para logging y depuración.
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

/// Sin conexión o timeout de red.
class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'Error de conexión', super.cause})
      : super(message);
}

/// Respuesta de error del servidor (4xx/5xx) distinta de los casos tratados.
class ServerFailure extends Failure {
  const ServerFailure(
    super.message, {
    this.statusCode,
    super.cause,
  });

  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Credenciales/sesión inválidas (401) o dispositivo revocado [DA-04].
class AuthFailure extends Failure {
  const AuthFailure({String message = 'Sesión inválida', super.cause})
      : super(message);
}

/// Versión de app por debajo de la mínima soportada (426) [DA-15].
class UpgradeRequiredFailure extends Failure {
  const UpgradeRequiredFailure({
    required this.minVersion,
    super.cause,
  }) : super('Actualización requerida');

  final String minVersion;

  @override
  List<Object?> get props => [...super.props, minVersion];
}

/// Error no categorizado.
class UnknownFailure extends Failure {
  const UnknownFailure({String message = 'Error inesperado', super.cause})
      : super(message);
}
