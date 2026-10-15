import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/domain/entities/auth_session.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: crear cuenta.
///
/// Recibe un [RegisterData] ya validado por los value objects del dominio
/// (correo, contraseña, celular E.164) y delega la creación al repositorio.
/// La validación de campo vive en los VOs/presentación para dar feedback
/// inmediato; aquí solo se asume ya validado y se orquesta la operación.
class Register {
  const Register(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession>> call(RegisterData data) {
    return _repository.register(data);
  }
}
