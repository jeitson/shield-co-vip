import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shield_app/core/secure/secure_providers.dart';
import 'package:uuid/uuid.dart';

/// Custodia del **device_id de instalación** (DA-02): un UUID propio generado al
/// primer arranque y guardado en secure storage. **No** es PII de hardware
/// (IMEI/Android ID), que el SO restringe y que violaría la minimización de datos.
///
/// Identifica al dispositivo ante el backend (`devices`, `v1-session`, header
/// `x-device-id`) de forma estable entre reinicios, sin exponer identidad física.
class DeviceIdStore {
  DeviceIdStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'device_id_v1';

  /// Devuelve el device_id existente o genera uno nuevo (UUID v4) la primera vez.
  Future<String> getOrCreate() async {
    final existing = await _storage.read(
      key: _key,
      aOptions: secureAndroidOptions,
    );
    if (existing != null && existing.isNotEmpty) return existing;

    final id = const Uuid().v4();
    await _storage.write(key: _key, value: id, aOptions: secureAndroidOptions);
    return id;
  }

  /// Lee el device_id si existe (sin crearlo).
  Future<String?> read() =>
      _storage.read(key: _key, aOptions: secureAndroidOptions);
}
