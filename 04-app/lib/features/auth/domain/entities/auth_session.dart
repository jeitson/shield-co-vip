import 'package:equatable/equatable.dart';
import 'package:shield_app/features/auth/domain/entities/user_account.dart';

/// Sesión autenticada del dispositivo.
///
/// Material sensible (DA-14): se custodia en secure storage, nunca en la SQLite
/// ni en logs. El access token vive 12h (DA-04); el refresh renueva verificando
/// que el dispositivo siga autorizado contra la tabla `devices`.
class AuthSession extends Equatable {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;

  /// Momento de expiración del access token (ventana 12h, DA-04).
  final DateTime expiresAt;

  /// Cuenta asociada a la sesión.
  final UserAccount user;

  /// `true` si el access token ya expiró (requiere refresh).
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Copia con nuevos tokens tras un refresh exitoso.
  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    UserAccount? user,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user,
    );
  }

  // No incluir tokens en props de logging accidental; Equatable los usa solo
  // para igualdad en memoria, no se exponen en toString de debug.
  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt, user];

  @override
  String toString() =>
      'AuthSession(user: ${user.correo}, expiresAt: $expiresAt)';
}
