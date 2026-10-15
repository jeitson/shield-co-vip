import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shield_app/features/auth/domain/value_objects/colombian_phone.dart';
import 'package:shield_app/features/auth/domain/value_objects/email.dart';
import 'package:shield_app/features/auth/domain/value_objects/password.dart';
import 'package:shield_app/features/auth/presentation/auth_providers.dart';
import 'package:shield_app/features/auth/presentation/state/register_form_state.dart';
import 'package:shield_app/features/auth/presentation/state/register_submit_state.dart';

/// Controla el formulario de registro y su envío.
final registerControllerProvider =
    NotifierProvider<RegisterController, RegisterFormState>(
      RegisterController.new,
    );

class RegisterController extends Notifier<RegisterFormState> {
  @override
  RegisterFormState build() => const RegisterFormState();

  void setNombre(String v) => state = state.copyWith(nombre: v);
  void setApellido(String v) => state = state.copyWith(apellido: v);
  void setCorreo(String v) => state = state.copyWith(correo: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  void setCelular(String v) => state = state.copyWith(celular: v);

  void togglePasswordVisibility() =>
      state = state.copyWith(showPassword: !state.showPassword);

  void setTermsAccepted(bool v) => state = state.copyWith(termsAccepted: v);
  void setPrivacyAccepted(bool v) => state = state.copyWith(privacyAccepted: v);

  /// Aplica errores de validación por campo al estado actual.
  void applyErrors({
    String? nombreError,
    String? apellidoError,
    String? correoError,
    String? passwordError,
    String? celularError,
  }) {
    state = state.withErrors(
      nombreError: nombreError,
      apellidoError: apellidoError,
      correoError: correoError,
      passwordError: passwordError,
      celularError: celularError,
    );
  }
}

/// Estado del submit de registro, con desenlaces de éxito explícitos
/// (sesión abierta vs. confirmación de correo pendiente).
final registerSubmissionProvider =
    NotifierProvider<RegisterSubmission, RegisterSubmitState>(
      RegisterSubmission.new,
    );

class RegisterSubmission extends Notifier<RegisterSubmitState> {
  @override
  RegisterSubmitState build() => const RegisterSubmitState.idle();

  /// Valida con los value objects del dominio y, si pasa, crea la cuenta.
  Future<void> submit() async {
    final controller = ref.read(registerControllerProvider.notifier);
    final form = ref.read(registerControllerProvider);

    if (!form.canSubmit) return; // consentimiento + obligatorios

    // Validación de formato (CA-REG-01/02/04 + RN-REG-04) vía VOs del dominio.
    final emailParsed = Email.tryParse(form.correo);
    final passwordParsed = Password.tryParse(form.password);
    final phoneParsed = ColombianPhone.tryParse(form.celular);

    final nombreError = form.nombre.trim().isEmpty
        ? 'El nombre es obligatorio'
        : null;
    final apellidoError = form.apellido.trim().isEmpty
        ? 'El apellido es obligatorio'
        : null;

    final hasErrors =
        nombreError != null ||
        apellidoError != null ||
        emailParsed.value == null ||
        passwordParsed.value == null ||
        phoneParsed.value == null;

    if (hasErrors) {
      controller.applyErrors(
        nombreError: nombreError,
        apellidoError: apellidoError,
        correoError: emailParsed.error,
        passwordError: passwordParsed.error,
        celularError: phoneParsed.error,
      );
      return;
    }

    state = const RegisterSubmitState.submitting();

    final data = RegisterData(
      nombre: form.nombre.trim(),
      apellido: form.apellido.trim(),
      correo: emailParsed.value!.value,
      password: passwordParsed.value!.value,
      celularE164: phoneParsed.value!.e164,
      terminosAceptados: form.termsAccepted,
      privacidadAceptada: form.privacyAccepted,
    );

    final result = await ref.read(registerUseCaseProvider).call(data);

    state = result.fold(
      (session) => RegisterSubmitState.success(session),
      (failure) => failure is EmailConfirmationPendingFailure
          // Éxito con confirmación pendiente, NO error.
          ? RegisterSubmitState.pendingConfirmation(failure.message)
          : RegisterSubmitState.error(failure),
    );
  }
}
