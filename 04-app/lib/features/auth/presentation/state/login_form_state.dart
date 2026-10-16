import 'package:equatable/equatable.dart';

/// Estado inmutable del formulario de login.
///
/// Inicia **vacío** (RN-LOGIN-02: nunca pre-rellenar credenciales). El login
/// **no** exige consentimientos: aceptar T&C y la nota de privacidad es un
/// requisito del **registro** (RN-REG-03), no del acceso de una cuenta que ya
/// los aceptó al crearse.
class LoginFormState extends Equatable {
  const LoginFormState({
    this.identifier = '',
    this.password = '',
    this.showPassword = false,
  });

  final String identifier;
  final String password;
  final bool showPassword;

  /// Habilitación del botón: ambos campos con contenido.
  bool get canSubmit => identifier.trim().isNotEmpty && password.isNotEmpty;

  LoginFormState copyWith({
    String? identifier,
    String? password,
    bool? showPassword,
  }) {
    return LoginFormState(
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      showPassword: showPassword ?? this.showPassword,
    );
  }

  @override
  List<Object?> get props => [identifier, password, showPassword];
}
