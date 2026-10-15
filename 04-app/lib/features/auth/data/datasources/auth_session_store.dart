import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shield_app/features/auth/data/dtos/auth_session_dto.dart';

/// Persistencia segura de la sesión (DA-14, `02-seguridad` §02.3).
///
/// Usa `flutter_secure_storage` (Android Keystore / iOS Keychain). Los tokens
/// nunca van a SharedPreferences plano ni a la SQLite. Serializa la sesión
/// completa como JSON bajo una única clave.
class AuthSessionStore {
  AuthSessionStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _sessionKey = 'auth_session_v1';

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  /// Lee la sesión persistida; `null` si no hay o está corrupta.
  Future<AuthSessionDto?> read() async {
    final raw = await _storage.read(
      key: _sessionKey,
      aOptions: _androidOptions,
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSessionDto.fromJson(json);
    } catch (_) {
      // Dato corrupto: limpiar para evitar bucles de error.
      await clear();
      return null;
    }
  }

  /// Guarda (o reemplaza) la sesión.
  Future<void> write(AuthSessionDto session) async {
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
      aOptions: _androidOptions,
    );
  }

  /// Borra el material de sesión (logout o revocación).
  Future<void> clear() async {
    await _storage.delete(key: _sessionKey, aOptions: _androidOptions);
  }
}
