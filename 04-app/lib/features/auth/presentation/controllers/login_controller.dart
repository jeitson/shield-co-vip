import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/features/auth/domain/entities/auth_session.dart';
import 'package:shield_app/features/auth/presentation/auth_providers.dart';
import 'package:shield_app/features/auth/presentation/state/login_form_state.dart';

/// Controla el formulario de login y su envío.
///
/// Separa dos responsabilidades:
/// - [state]: el formulario (campos, consentimientos, visibilidad) — síncrono.
/// - [submission]: el estado async del envío (cargando/éxito/error) para que la
///   UI pinte el botón y los errores con los cuatro estados del dominio.
final loginControllerProvider =
    NotifierProvider<LoginController, LoginFormState>(LoginController.new);

class LoginController extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormState();

  void setIdentifier(String value) => state = state.copyWith(identifier: value);

  void setPassword(String value) => state = state.copyWith(password: value);

  void togglePasswordVisibility() =>
      state = state.copyWith(showPassword: !state.showPassword);
}

/// Estado asíncrono del submit de login (independiente del formulario).
final loginSubmissionProvider =
    AsyncNotifierProvider<LoginSubmission, AuthSession?>(LoginSubmission.new);

class LoginSubmission extends AsyncNotifier<AuthSession?> {
  @override
  AuthSession? build() => null;

  /// Ejecuta el login. Devuelve `true` si fue exitoso (para navegar).
  Future<bool> submit() async {
    final form = ref.read(loginControllerProvider);
    if (!form.canSubmit) return false; // ambos campos con contenido

    state = const AsyncLoading();
    final result = await ref
        .read(loginUseCaseProvider)
        .call(identifier: form.identifier, password: form.password);

    return result.fold(
      (session) {
        state = AsyncData(session);
        return true;
      },
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
    );
  }
}
