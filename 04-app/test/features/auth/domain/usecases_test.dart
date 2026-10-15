import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/domain/entities/auth_session.dart';
import 'package:shield_app/features/auth/domain/entities/user_account.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shield_app/features/auth/domain/usecases/login.dart';
import 'package:shield_app/features/auth/domain/usecases/request_password_reset.dart';
import 'package:shield_app/features/auth/domain/usecases/resend_confirmation.dart';

/// Repositorio falso configurable para ejercitar los casos de uso sin
/// infraestructura.
class _FakeAuthRepository implements AuthRepository {
  Result<AuthSession> loginResult = Ok(_session());
  String? lastIdentifier;
  bool resetCalled = false;
  bool resendCalled = false;

  @override
  Future<Result<AuthSession>> login({
    required String identifier,
    required String password,
  }) async {
    lastIdentifier = identifier;
    return loginResult;
  }

  @override
  Future<Result<AuthSession>> register(RegisterData data) async =>
      Ok(_session());

  @override
  Future<Result<void>> logout() async => const Ok(null);

  @override
  Future<Result<AuthSession?>> restoreSession() async => const Ok(null);

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    resetCalled = true;
    return const Ok(null);
  }

  @override
  Future<Result<void>> resendConfirmation(String email) async {
    resendCalled = true;
    return const Ok(null);
  }

  @override
  Stream<AuthSession?> watchSession() => const Stream.empty();
}

AuthSession _session() => AuthSession(
  accessToken: 'a',
  refreshToken: 'r',
  expiresAt: DateTime.now().add(const Duration(hours: 12)),
  user: const UserAccount(
    id: '1',
    correo: 'x@y.z',
    nombre: 'X',
    apellido: 'Y',
    celular: '+573001234567',
    terminosAceptados: true,
    privacidadAceptada: true,
  ),
);

void main() {
  group('Login use case', () {
    test('rechaza credenciales vacías sin tocar el repositorio', () async {
      final repo = _FakeAuthRepository();
      final login = Login(repo);

      final result = await login(identifier: '  ', password: '');

      expect(result.isErr, isTrue);
      expect(repo.lastIdentifier, isNull);
    });

    test('recorta el identificador y delega al repositorio', () async {
      final repo = _FakeAuthRepository();
      final login = Login(repo);

      final result = await login(identifier: '  user@x.co ', password: 'pw');

      expect(result.isOk, isTrue);
      expect(repo.lastIdentifier, 'user@x.co');
    });

    test('propaga el error del repositorio', () async {
      final repo = _FakeAuthRepository()
        ..loginResult = const Err(ServerFailure('Credenciales'));
      final login = Login(repo);

      final result = await login(identifier: 'a', password: 'b');

      expect(result.isErr, isTrue);
    });
  });

  group('RequestPasswordReset use case', () {
    test('rechaza correo inválido antes de llamar al repositorio', () async {
      final repo = _FakeAuthRepository();
      final reset = RequestPasswordReset(repo);

      final result = await reset('no-es-correo');

      expect(result.isErr, isTrue);
      expect(repo.resetCalled, isFalse);
    });

    test('acepta correo válido y delega', () async {
      final repo = _FakeAuthRepository();
      final reset = RequestPasswordReset(repo);

      final result = await reset('user@dominio.co');

      expect(result.isOk, isTrue);
      expect(repo.resetCalled, isTrue);
    });
  });

  group('ResendConfirmation use case', () {
    test('rechaza correo inválido antes de llamar al repositorio', () async {
      final repo = _FakeAuthRepository();
      final resend = ResendConfirmation(repo);

      final result = await resend('correo-malo');

      expect(result.isErr, isTrue);
      expect(repo.resendCalled, isFalse);
    });

    test('acepta correo válido y delega', () async {
      final repo = _FakeAuthRepository();
      final resend = ResendConfirmation(repo);

      final result = await resend('user@dominio.co');

      expect(result.isOk, isTrue);
      expect(repo.resendCalled, isTrue);
    });
  });
}
