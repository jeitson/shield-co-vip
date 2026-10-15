import 'package:equatable/equatable.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/domain/entities/auth_session.dart';

/// Datos ya validados para crear una cuenta.
///
/// Los value objects del dominio garantizan que `correo` y `celular` llegan
/// normalizados (E.164) y `password` cumple la política antes de construir esto.
class RegisterData extends Equatable {
  const RegisterData({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.password,
    required this.celularE164,
    required this.terminosAceptados,
    required this.privacidadAceptada,
  });

  final String nombre;
  final String apellido;
  final String correo;
  final String password;
  final String celularE164;
  final bool terminosAceptados;
  final bool privacidadAceptada;

  @override
  List<Object?> get props => [
    nombre,
    apellido,
    correo,
    celularE164,
    terminosAceptados,
    privacidadAceptada,
  ];
}

/// Contrato de autenticación (DN-01: opera contra backend; MVP con impl fake).
///
/// Devuelve `Result` en vez de lanzar, para forzar el manejo explícito del
/// error en presentación (`core/error`). La implementación compone el data
/// source remoto con el almacenamiento seguro de la sesión.
abstract interface class AuthRepository {
  /// Inicia sesión con identificador/correo + clave. Persiste la sesión.
  Future<Result<AuthSession>> login({
    required String identifier,
    required String password,
  });

  /// Crea una cuenta y abre sesión. Persiste la sesión.
  Future<Result<AuthSession>> register(RegisterData data);

  /// Cierra sesión y borra el material local.
  Future<Result<void>> logout();

  /// Restaura la sesión persistida al arrancar. `null` = sin sesión válida.
  Future<Result<AuthSession?>> restoreSession();

  /// Inicia la recuperación de clave estándar por email (DA-04).
  Future<Result<void>> requestPasswordReset(String email);

  /// Reenvía el correo de confirmación de registro (R7 · RN-LOGIN-04).
  Future<Result<void>> resendConfirmation(String email);

  /// Flujo del estado de sesión para el guard de navegación.
  Stream<AuthSession?> watchSession();
}
