import 'package:shield_app/features/auth/data/dtos/user_account_dto.dart';
import 'package:shield_app/features/auth/domain/entities/auth_session.dart';

/// DTO de sesión (serialización ↔ secure storage / backend).
///
/// Persiste tokens y expiración junto a la cuenta. Material sensible (DA-14):
/// solo se escribe en secure storage, nunca en SQLite ni logs.
class AuthSessionDto {
  const AuthSessionDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final UserAccountDto user;

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) => AuthSessionDto(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    expiresAt: DateTime.parse(json['expires_at'] as String),
    user: UserAccountDto.fromJson(
      Map<String, dynamic>.from(json['user'] as Map),
    ),
  );

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'expires_at': expiresAt.toIso8601String(),
    'user': user.toJson(),
  };

  factory AuthSessionDto.fromEntity(AuthSession session) => AuthSessionDto(
    accessToken: session.accessToken,
    refreshToken: session.refreshToken,
    expiresAt: session.expiresAt,
    user: UserAccountDto.fromEntity(session.user),
  );

  AuthSession toEntity() => AuthSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresAt: expiresAt,
    user: user.toEntity(),
  );
}
