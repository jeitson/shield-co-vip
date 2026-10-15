import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shield_app/features/auth/domain/value_objects/email.dart';

/// Caso de uso: reenviar el correo de confirmación de registro (R7).
///
/// Valida el formato del correo antes de delegar. La respuesta debe tratarse de
/// forma neutra en la UI (anti-enumeración): no revelar si la cuenta existe o
/// su estado de confirmación.
class ResendConfirmation {
  const ResendConfirmation(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(String rawEmail) {
    final parsed = Email.tryParse(rawEmail);
    if (parsed.value == null) {
      return Future.value(
        Err(ServerFailure(parsed.error ?? 'Correo inválido')),
      );
    }
    return _repository.resendConfirmation(parsed.value!.value);
  }
}
