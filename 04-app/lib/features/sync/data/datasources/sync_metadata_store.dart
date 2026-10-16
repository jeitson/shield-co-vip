import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shield_app/core/secure/secure_providers.dart';

/// Metadatos locales del sync: última versión aplicada y marca de tiempo del
/// último éxito. No es material criptográfico, pero se guarda junto al resto de
/// claves por simplicidad y para sobrevivir reinstalaciones de la base.
class SyncMetadataStore {
  SyncMetadataStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _versionKey = 'sync_last_version_v1';
  static const _atKey = 'sync_last_at_v1';

  /// Última versión del dataset aplicada localmente (0 si nunca se sincronizó).
  Future<int> lastSyncedVersion() async {
    final raw = await _storage.read(
      key: _versionKey,
      aOptions: secureAndroidOptions,
    );
    return int.tryParse(raw ?? '') ?? 0;
  }

  /// Marca de tiempo del último sync exitoso; `null` si nunca.
  Future<DateTime?> lastSyncedAt() async {
    final raw = await _storage.read(
      key: _atKey,
      aOptions: secureAndroidOptions,
    );
    return raw == null ? null : DateTime.tryParse(raw);
  }

  /// Persiste la versión aplicada y la fecha de éxito.
  Future<void> save({required int version, required DateTime at}) async {
    await _storage.write(
      key: _versionKey,
      value: version.toString(),
      aOptions: secureAndroidOptions,
    );
    await _storage.write(
      key: _atKey,
      value: at.toIso8601String(),
      aOptions: secureAndroidOptions,
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _versionKey, aOptions: secureAndroidOptions);
    await _storage.delete(key: _atKey, aOptions: secureAndroidOptions);
  }
}
