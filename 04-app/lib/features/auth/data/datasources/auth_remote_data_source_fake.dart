import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shield_app/features/auth/data/dtos/auth_session_dto.dart';
import 'package:shield_app/features/auth/data/dtos/user_account_dto.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';

/// Implementación en memoria del contrato remoto para el MVP (sin backend real).
///
/// Modela los caminos felices y de error de verdad (credenciales inválidas,
/// correo/celular duplicado, latencia) para ejercitar la UI con los cuatro
/// estados del dominio. **No** expone credenciales a la UI (RN-LOGIN-02): el
/// usuario semilla vive solo aquí, para poder validar el flujo completo.
///
/// Cuando exista el backend Supabase, se sustituye por una impl sobre
/// `ApiClient`/Dio sin tocar dominio ni presentación (un solo provider cambia).
class AuthRemoteDataSourceFake implements AuthRemoteDataSource {
  AuthRemoteDataSourceFake();

  /// "Base de datos" en memoria: correo → registro.
  final Map<String, _FakeUser> _usersByEmail = {
    'seguridad@nodo.zero': const _FakeUser(
      id: 'usr_seed_0001',
      nombre: 'Nodo',
      apellido: 'Seguro',
      correo: 'seguridad@nodo.zero',
      celular: '+573001234567',
      password: 'cifradocero2026',
    ),
  };

  static const _latency = Duration(milliseconds: 900);

  @override
  Future<Result<AuthSessionDto>> login({
    required String identifier,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);

    final key = identifier.trim().toLowerCase();
    final user = _usersByEmail[key];

    if (user == null || user.password != password) {
      return const Err(ServerFailure('Identificador o clave incorrectos'));
    }

    return Ok(_sessionFor(user));
  }

  @override
  Future<Result<AuthSessionDto>> register(RegisterData data) async {
    await Future<void>.delayed(_latency);

    final emailKey = data.correo.toLowerCase();
    if (_usersByEmail.containsKey(emailKey)) {
      return const Err(ServerFailure('Ya existe una cuenta con ese correo'));
    }
    final phoneTaken = _usersByEmail.values.any(
      (u) => u.celular == data.celularE164,
    );
    if (phoneTaken) {
      return const Err(ServerFailure('Ya existe una cuenta con ese celular'));
    }

    final user = _FakeUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      nombre: data.nombre,
      apellido: data.apellido,
      correo: data.correo,
      celular: data.celularE164,
      password: data.password,
    );
    _usersByEmail[emailKey] = user;

    return Ok(_sessionFor(user));
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    await Future<void>.delayed(_latency);
    // Respuesta neutra a propósito: no revelar si el correo existe
    // (buena práctica anti-enumeración). El envío real lo hará Supabase Auth.
    return const Ok(null);
  }

  @override
  Future<Result<void>> resendConfirmation(String email) async {
    await Future<void>.delayed(_latency);
    // El fake no exige confirmación; respuesta neutra (anti-enumeración).
    return const Ok(null);
  }

  @override
  Future<Result<void>> signOut() async {
    // El fake no mantiene sesión propia; nada que cerrar en remoto.
    return const Ok(null);
  }

  AuthSessionDto _sessionFor(_FakeUser user) {
    final now = DateTime.now();
    return AuthSessionDto(
      accessToken: 'fake_access_${user.id}_${now.millisecondsSinceEpoch}',
      refreshToken: 'fake_refresh_${user.id}',
      // Ventana de 12h (DA-04).
      expiresAt: now.add(const Duration(hours: 12)),
      user: UserAccountDto(
        id: user.id,
        correo: user.correo,
        nombre: user.nombre,
        apellido: user.apellido,
        celular: user.celular,
        terminosAceptados: true,
        privacidadAceptada: true,
      ),
    );
  }
}

/// Registro mínimo del usuario semilla/creado en el fake.
class _FakeUser {
  const _FakeUser({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.celular,
    required this.password,
  });

  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String celular;
  final String password;
}
