import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shield_app/core/secure/secure_providers.dart';

/// Custodia del **pepper** del dataset en el keystore (`02-seguridad` §02.2).
///
/// El pepper es la clave HMAC con la que el servidor calcula los hashes del
/// dataset y con la que el dispositivo hashea el número **entrante** para el
/// matching offline. Se obtiene de `v1-pepper` tras autenticarse y se guarda en
/// el keystore del SO; **nunca** en la base local ni en logs. Se versiona
/// (`pepper_version`) para detectar rotaciones (full-resync).
class PepperStore {
  PepperStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _pepperKey = 'dataset_pepper_v1';
  static const _versionKey = 'dataset_pepper_version_v1';

  /// Lee el pepper guardado; `null` si aún no se ha obtenido.
  Future<String?> readPepper() =>
      _storage.read(key: _pepperKey, aOptions: secureAndroidOptions);

  /// Lee la versión del pepper guardada; `null` si no hay.
  Future<int?> readVersion() async {
    final raw = await _storage.read(
      key: _versionKey,
      aOptions: secureAndroidOptions,
    );
    return raw == null ? null : int.tryParse(raw);
  }

  /// Guarda (o reemplaza) el pepper y su versión.
  Future<void> write(String pepper, int version) async {
    await _storage.write(
      key: _pepperKey,
      value: pepper,
      aOptions: secureAndroidOptions,
    );
    await _storage.write(
      key: _versionKey,
      value: version.toString(),
      aOptions: secureAndroidOptions,
    );
  }

  /// Borra el material (logout / revocación de dispositivo, DA-04).
  Future<void> clear() async {
    await _storage.delete(key: _pepperKey, aOptions: secureAndroidOptions);
    await _storage.delete(key: _versionKey, aOptions: secureAndroidOptions);
  }
}
