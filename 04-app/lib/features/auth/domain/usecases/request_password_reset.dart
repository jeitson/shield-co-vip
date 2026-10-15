import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shield_app/features/auth/domain/value_objects/email.dart';

/// Caso de uso: solicitar recuperación de clave por email (DA-04).
///
/// Bajo este modelo la recuperación es estándar vía Supabase Auth; no hay seed
/// phrase ni llave de respaldo (`02-seguridad` §02.4). Perder la clave no borra
/// los datos locales (DEK independiente en keystore).
class RequestPasswordReset {
  const RequestPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(String rawEmail) {
    final parsed = Email.tryParse(rawEmail);
    if (parsed.value == null) {
      return Future.value(
        Err(ServerFailure(parsed.error ?? 'Correo inválido')),
      );
    }
    return _repository.requestPasswordReset(parsed.value!.value);
  }
}
