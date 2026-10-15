import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/domain/entities/auth_session.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: iniciar sesión.
///
/// Valida presencia de credenciales (el formato de identificador se delega al
/// backend, que puede aceptar correo o alias) y delega en el repositorio.
class Login {
  const Login(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession>> call({
    required String identifier,
    required String password,
  }) {
    final id = identifier.trim();
    if (id.isEmpty || password.isEmpty) {
      return Future.value(
        const Err(ServerFailure('Ingresa tu identificador y tu clave')),
      );
    }
    return _repository.login(identifier: id, password: password);
  }
}
