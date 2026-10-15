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
  const ServerFailure(super.message, {this.statusCode, super.cause});

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
  const UpgradeRequiredFailure({required this.minVersion, super.cause})
    : super('Actualización requerida');

  final String minVersion;

  @override
  List<Object?> get props => [...super.props, minVersion];
}

/// Error no categorizado.
class UnknownFailure extends Failure {
  const UnknownFailure({String message = 'Error inesperado', super.cause})
    : super(message);
}

/// Caso **informativo**, no de error: la cuenta se creó pero requiere
/// confirmación de correo antes de poder iniciar sesión (política del proyecto
/// Supabase). Se modela como [Failure] porque interrumpe el flujo de "abrir
/// sesión", pero la UI debe mostrarlo como éxito/aviso, no como error rojo.
class EmailConfirmationPendingFailure extends Failure {
  const EmailConfirmationPendingFailure({
    String message =
        'Cuenta creada. Te enviamos un correo para confirmar tu cuenta antes de ingresar.',
    super.cause,
  }) : super(message);
}

/// Intento de **login** con una cuenta cuyo correo aún no fue confirmado
/// (R7 · RN-LOGIN-04). La UI debe bloquear el acceso y ofrecer reenviar el
/// correo de confirmación. Lleva el correo intentado para facilitar el reenvío.
class EmailNotConfirmedFailure extends Failure {
  const EmailNotConfirmedFailure({
    this.email,
    String message =
        'Tu correo aún no está confirmado. Revisa tu bandeja o reenvía el enlace.',
    super.cause,
  }) : super(message);

  /// Correo con el que se intentó iniciar sesión (si se conoce).
  final String? email;

  @override
  List<Object?> get props => [...super.props, email];
}
