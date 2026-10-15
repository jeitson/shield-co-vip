import 'package:equatable/equatable.dart';

/// Estado inmutable del formulario de registro, con errores por campo (R2).
class RegisterFormState extends Equatable {
  const RegisterFormState({
    this.nombre = '',
    this.apellido = '',
    this.correo = '',
    this.password = '',
    this.celular = '',
    this.showPassword = false,
    this.termsAccepted = false,
    this.privacyAccepted = false,
    this.nombreError,
    this.apellidoError,
    this.correoError,
    this.passwordError,
    this.celularError,
  });

  final String nombre;
  final String apellido;
  final String correo;
  final String password;
  final String celular;
  final bool showPassword;
  final bool termsAccepted;
  final bool privacyAccepted;

  // Errores de validación por campo (null = sin error).
  final String? nombreError;
  final String? apellidoError;
  final String? correoError;
  final String? passwordError;
  final String? celularError;

  bool get consentGiven => termsAccepted && privacyAccepted;

  /// Campos obligatorios con contenido (CA-REG-01). La validación de formato
  /// detallada ocurre al enviar (vía value objects del dominio).
  bool get hasRequiredFields =>
      nombre.trim().isNotEmpty &&
      apellido.trim().isNotEmpty &&
      correo.trim().isNotEmpty &&
      password.isNotEmpty &&
      celular.trim().isNotEmpty;

  /// Habilitación del botón "Crear cuenta".
  bool get canSubmit => consentGiven && hasRequiredFields;

  RegisterFormState copyWith({
    String? nombre,
    String? apellido,
    String? correo,
    String? password,
    String? celular,
    bool? showPassword,
    bool? termsAccepted,
    bool? privacyAccepted,
  }) {
    return RegisterFormState(
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      password: password ?? this.password,
      celular: celular ?? this.celular,
      showPassword: showPassword ?? this.showPassword,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      privacyAccepted: privacyAccepted ?? this.privacyAccepted,
      // Al editar, limpiar los errores (se recalculan al enviar).
      nombreError: null,
      apellidoError: null,
      correoError: null,
      passwordError: null,
      celularError: null,
    );
  }

  /// Copia aplicando los errores de validación calculados al enviar.
  RegisterFormState withErrors({
    String? nombreError,
    String? apellidoError,
    String? correoError,
    String? passwordError,
    String? celularError,
  }) {
    return RegisterFormState(
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      password: password,
      celular: celular,
      showPassword: showPassword,
      termsAccepted: termsAccepted,
      privacyAccepted: privacyAccepted,
      nombreError: nombreError,
      apellidoError: apellidoError,
      correoError: correoError,
      passwordError: passwordError,
      celularError: celularError,
    );
  }

  bool get hasFieldErrors =>
      nombreError != null ||
      apellidoError != null ||
      correoError != null ||
      passwordError != null ||
      celularError != null;

  @override
  List<Object?> get props => [
    nombre,
    apellido,
    correo,
    password,
    celular,
    showPassword,
    termsAccepted,
    privacyAccepted,
    nombreError,
    apellidoError,
    correoError,
    passwordError,
    celularError,
  ];
}
