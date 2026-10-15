import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/data/dtos/auth_session_dto.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';

/// Contrato de la fuente remota de autenticación (DN-01).
///
/// Lo implementa hoy un fake en memoria (`AuthRemoteDataSourceFake`) para el
/// MVP sin backend real, y a futuro una impl sobre Supabase/Dio (`ApiClient`,
/// contratos `/v1` de `05-backend-api-metricas`). Devuelve `Result` con DTOs;
/// el mapeo a entidades y la custodia de la sesión viven en el repositorio.
abstract interface class AuthRemoteDataSource {
  Future<Result<AuthSessionDto>> login({
    required String identifier,
    required String password,
  });

  Future<Result<AuthSessionDto>> register(RegisterData data);

  Future<Result<void>> requestPasswordReset(String email);

  /// Reenvía el correo de confirmación de registro a [email] (R7).
  Future<Result<void>> resendConfirmation(String email);

  /// Cierra la sesión en el proveedor remoto (p. ej. Supabase Auth), para que
  /// su propia persistencia no reautentique tras el logout local.
  Future<Result<void>> signOut();
}
