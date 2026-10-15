import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: cerrar sesión y borrar material local.
class Logout {
  const Logout(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.logout();
}
