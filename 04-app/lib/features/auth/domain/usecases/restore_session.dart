import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/domain/entities/auth_session.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: restaurar la sesión persistida al arrancar la app (R3.2).
///
/// Devuelve `null` cuando no hay sesión válida, de modo que el guard de
/// navegación lleve a login sin tratarlo como error.
class RestoreSession {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession?>> call() => _repository.restoreSession();
}
