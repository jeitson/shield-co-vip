import 'dart:async';

import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shield_app/features/auth/data/datasources/auth_session_store.dart';
import 'package:shield_app/features/auth/data/dtos/auth_session_dto.dart';
import 'package:shield_app/features/auth/domain/entities/auth_session.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';

/// Implementación del contrato de autenticación.
///
/// Compone la fuente remota (DN-01) con el almacenamiento seguro de la sesión
/// (DA-14) y emite el estado por un stream que alimenta el guard de navegación.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.remote, required this.store});

  final AuthRemoteDataSource remote;
  final AuthSessionStore store;

  final StreamController<AuthSession?> _sessionController =
      StreamController<AuthSession?>.broadcast();

  @override
  Future<Result<AuthSession>> login({
    required String identifier,
    required String password,
  }) async {
    final result = await remote.login(
      identifier: identifier,
      password: password,
    );
    return _persistAndEmit(result);
  }

  @override
  Future<Result<AuthSession>> register(RegisterData data) async {
    final result = await remote.register(data);
    return _persistAndEmit(result);
  }

  @override
  Future<Result<void>> logout() async {
    // Cerrar primero en el proveedor remoto para que su persistencia no
    // reautentique, luego borrar el material local. El cierre local manda.
    await remote.signOut();
    await store.clear();
    _sessionController.add(null);
    return const Ok(null);
  }

  @override
  Future<Result<AuthSession?>> restoreSession() async {
    try {
      final dto = await store.read();
      if (dto == null) {
        _sessionController.add(null);
        return const Ok(null);
      }
      final session = dto.toEntity();
      // En el MVP, una sesión expirada se descarta (sin backend de refresh).
      // Con Supabase, aquí se intentará `/v1/session/refresh` (DA-04) y, si
      // el dispositivo fue revocado, se borra el material y cae a desprotegido.
      if (session.isExpired) {
        await store.clear();
        _sessionController.add(null);
        return const Ok(null);
      }
      _sessionController.add(session);
      return Ok(session);
    } catch (e) {
      return Err(
        UnknownFailure(message: 'No se pudo restaurar la sesión', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) {
    return remote.requestPasswordReset(email);
  }

  @override
  Future<Result<void>> resendConfirmation(String email) {
    return remote.resendConfirmation(email);
  }

  @override
  Stream<AuthSession?> watchSession() => _sessionController.stream;

  /// Mapea el DTO a entidad, lo persiste de forma segura y emite al stream.
  Future<Result<AuthSession>> _persistAndEmit(
    Result<AuthSessionDto> result,
  ) async {
    return switch (result) {
      Ok<AuthSessionDto>(:final value) => await () async {
        await store.write(value);
        final session = value.toEntity();
        _sessionController.add(session);
        return Ok<AuthSession>(session);
      }(),
      Err<AuthSessionDto>(:final failure) => Err<AuthSession>(failure),
    };
  }

  /// Libera el controlador del stream.
  void dispose() {
    _sessionController.close();
  }
}
