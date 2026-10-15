import 'package:equatable/equatable.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/features/auth/domain/entities/auth_session.dart';

/// Fase del envío del registro. Modela el resultado como estados de **éxito**
/// explícitos (incluido "confirmación pendiente") en vez de tratar ese caso
/// como un error, para que la UI pueda deshabilitar controles, mostrar el
/// aviso correcto y redirigir.
enum RegisterPhase {
  /// Formulario editable, sin envío en curso.
  idle,

  /// Envío en curso ("Blindando Identidad…").
  submitting,

  /// Cuenta creada **con sesión abierta** → se puede ir al Dashboard.
  success,

  /// Cuenta creada pero requiere confirmar el correo antes de ingresar.
  /// Es un éxito: se avisa y se redirige al login.
  pendingConfirmation,

  /// Falló (validación ya se maneja aparte; aquí van errores de servidor/red).
  error,
}

/// Estado inmutable del envío del registro.
class RegisterSubmitState extends Equatable {
  const RegisterSubmitState({
    this.phase = RegisterPhase.idle,
    this.session,
    this.message,
    this.failure,
  });

  final RegisterPhase phase;

  /// Sesión abierta (solo en [RegisterPhase.success]).
  final AuthSession? session;

  /// Mensaje a mostrar (éxito/aviso/error).
  final String? message;

  /// Error subyacente (solo en [RegisterPhase.error]).
  final Failure? failure;

  bool get isSubmitting => phase == RegisterPhase.submitting;

  /// `true` en cualquier desenlace de éxito (abra sesión o requiera confirmar):
  /// la UI deshabilita los controles y muestra el botón "hecho".
  bool get isDone =>
      phase == RegisterPhase.success ||
      phase == RegisterPhase.pendingConfirmation;

  bool get isError => phase == RegisterPhase.error;

  const RegisterSubmitState.idle() : this();

  const RegisterSubmitState.submitting() : this(phase: RegisterPhase.submitting);

  const RegisterSubmitState.success(AuthSession session)
    : this(phase: RegisterPhase.success, session: session);

  const RegisterSubmitState.pendingConfirmation(String message)
    : this(phase: RegisterPhase.pendingConfirmation, message: message);

  RegisterSubmitState.error(Failure failure)
    : this(
        phase: RegisterPhase.error,
        failure: failure,
        message: failure.message,
      );

  @override
  List<Object?> get props => [phase, session, message, failure];
}
