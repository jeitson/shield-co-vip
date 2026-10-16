import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shield_app/core/secure/secure_providers.dart';

/// Custodia de la **DEK** (Data Encryption Key) de la base local cifrada
/// (`02-seguridad` §02.3, DA-07/DA-14).
///
/// La DEK son 256 bits aleatorios generados **una sola vez** en el primer
/// arranque y guardados en el keystore del SO (vía `flutter_secure_storage`,
/// respaldado por Android Keystore). Propiedades clave del diseño:
///
/// - **Independiente de la contraseña del usuario:** nunca se deriva de
///   credenciales. Un reset de clave por email no la cambia, así que la base
///   local sigue siendo legible tras recuperar la cuenta.
/// - **Nunca** se escribe en la propia base, ni en logs, ni en almacenamiento
///   plano. Solo vive en el keystore.
/// - Borrarla (revocación/wipe) vuelve la base ilegible; el próximo arranque
///   genera una DEK nueva y una base vacía (comportamiento esperado y correcto).
class LocalCryptoKeys {
  LocalCryptoKeys(this._storage);

  final FlutterSecureStorage _storage;

  /// Clave de almacenamiento de la DEK. Versionada por si cambia el formato.
  static const _dekKey = 'local_db_dek_v1';

  /// Longitud de la DEK en bytes (256 bits).
  static const _dekBytes = 32;

  /// Devuelve la DEK existente o genera una nueva de 256 bits la primera vez.
  ///
  /// El valor devuelto es la DEK en base64, apta para usarse como passphrase de
  /// `PRAGMA key` al abrir la base cifrada.
  Future<String> getOrCreateDek() async {
    final existing = await _storage.read(
      key: _dekKey,
      aOptions: secureAndroidOptions,
    );
    if (existing != null && existing.isNotEmpty) return existing;

    final dek = _generateDek();
    await _storage.write(
      key: _dekKey,
      value: dek,
      aOptions: secureAndroidOptions,
    );
    return dek;
  }

  /// Borra la DEK del keystore (revocación de dispositivo o cierre de sesión con
  /// wipe de material sensible, DA-04). Tras esto la base deja de ser legible.
  Future<void> deleteDek() async {
    await _storage.delete(key: _dekKey, aOptions: secureAndroidOptions);
  }

  /// Genera 256 bits de alta entropía con un CSPRNG y los codifica en base64.
  String _generateDek() {
    final rng = Random.secure();
    final bytes = List<int>.generate(_dekBytes, (_) => rng.nextInt(256));
    return base64Encode(bytes);
  }
}
