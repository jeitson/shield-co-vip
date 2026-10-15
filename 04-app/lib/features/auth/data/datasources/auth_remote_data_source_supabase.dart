import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shield_app/features/auth/data/dtos/auth_session_dto.dart';
import 'package:shield_app/features/auth/data/dtos/user_account_dto.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación real del contrato de autenticación contra **Supabase Auth**
/// (DN-01, DA-11). Traduce signUp / signInWithPassword / resetPasswordForEmail
/// a `Result<AuthSessionDto>` y mapea los errores de Supabase a los [Failure]
/// del dominio. No cambia dominio ni presentación.
///
/// El perfil (nombre/apellido/celular/consentimientos) se envía como metadatos
/// del alta; el trigger `handle_new_user` crea la fila en `profiles`.
class AuthRemoteDataSourceSupabase implements AuthRemoteDataSource {
  AuthRemoteDataSourceSupabase(this._auth);

  final GoTrueClient _auth;

  @override
  Future<Result<AuthSessionDto>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: identifier,
        password: password,
      );
      return _toSession(response.session, response.user);
    } on AuthException catch (e) {
      // Caso especial: correo sin confirmar → failure dedicado con el correo,
      // para que la UI ofrezca reenviar (R7 · RN-LOGIN-04).
      if (e.message.toLowerCase().contains('email not confirmed')) {
        return Err(EmailNotConfirmedFailure(email: identifier, cause: e));
      }
      return Err(_mapAuthError(e));
    } catch (e) {
      return Err(NetworkFailure(cause: e));
    }
  }

  @override
  Future<Result<AuthSessionDto>> register(RegisterData data) async {
    try {
      final response = await _auth.signUp(
        email: data.correo,
        password: data.password,
        // Metadatos que lee el trigger `handle_new_user` para poblar `profiles`.
        data: {
          'nombre': data.nombre,
          'apellido': data.apellido,
          'celular': data.celularE164,
          'terminos_aceptados': data.terminosAceptados,
          'privacidad_aceptada': data.privacidadAceptada,
        },
      );
      // Si el proyecto exige confirmación por email, `session` llega null:
      // la cuenta se creó pero no hay sesión hasta confirmar.
      if (response.session == null) {
        return const Err(EmailConfirmationPendingFailure());
      }
      return _toSession(response.session, response.user);
    } on AuthException catch (e) {
      return Err(_mapAuthError(e));
    } catch (e) {
      return Err(NetworkFailure(cause: e));
    }
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
      return const Ok(null);
    } on AuthException catch (e) {
      return Err(_mapAuthError(e));
    } catch (e) {
      return Err(NetworkFailure(cause: e));
    }
  }

  @override
  Future<Result<void>> resendConfirmation(String email) async {
    try {
      await _auth.resend(type: OtpType.signup, email: email);
      return const Ok(null);
    } on AuthException catch (e) {
      return Err(_mapAuthError(e));
    } catch (e) {
      return Err(NetworkFailure(cause: e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Ok(null);
    } catch (e) {
      // El cierre local manda; si el signOut remoto falla, no bloquear el logout.
      return const Ok(null);
    }
  }

  /// Construye el DTO de sesión a partir de la respuesta de Supabase.
  ///
  /// El perfil se arma con los metadatos del usuario (`userMetadata`); la
  /// lectura canónica de `profiles` por RLS puede hacerse después si se
  /// necesita el estado persistido.
  Result<AuthSessionDto> _toSession(Session? session, User? user) {
    if (session == null || user == null) {
      return const Err(AuthFailure(message: 'No se pudo abrir la sesión'));
    }
    final meta = user.userMetadata ?? const {};
    final expiresAt = session.expiresAt != null
        ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
        : DateTime.now().add(const Duration(hours: 1));

    final dto = AuthSessionDto(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      expiresAt: expiresAt,
      user: UserAccountDto(
        id: user.id,
        correo: user.email ?? (meta['correo'] as String? ?? ''),
        nombre: meta['nombre'] as String? ?? '',
        apellido: meta['apellido'] as String? ?? '',
        celular: meta['celular'] as String? ?? '',
        terminosAceptados: meta['terminos_aceptados'] as bool? ?? false,
        privacidadAceptada: meta['privacidad_aceptada'] as bool? ?? false,
      ),
    );
    return Ok(dto);
  }

  /// Mapea errores de Supabase Auth a [Failure] del dominio con mensajes claros
  /// (RF-LOGIN-06). Supabase devuelve mensajes en inglés; se traducen los casos
  /// frecuentes y se cae a uno genérico para el resto.
  Failure _mapAuthError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
      return const AuthFailure(message: 'Identificador o clave incorrectos');
    }
    if (msg.contains('already registered') ||
        msg.contains('already been registered') ||
        msg.contains('user already')) {
      return const ServerFailure('Ya existe una cuenta con ese correo');
    }
    if (msg.contains('email not confirmed')) {
      return const ServerFailure('Debes confirmar tu correo antes de ingresar');
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return const ServerFailure('Demasiados intentos. Inténtalo más tarde.');
    }
    return ServerFailure(e.message, cause: e);
  }
}
