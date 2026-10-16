import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shield_app/core/secure/secure_providers.dart';
import 'package:shield_app/features/device/data/hardware_id_source.dart';
import 'package:uuid/uuid.dart';

/// Custodia del **device_id de instalación** (DA-02).
///
/// Para que el `device_id` **sobreviva a reinstalaciones** (y no dispare la
/// exclusividad de dispositivo del servidor al reinstalar, DA-03), se **deriva
/// de un identificador de hardware estable** (`ANDROID_ID`) mediante un UUID v5
/// determinista. Así:
///  - El mismo equipo produce **siempre el mismo** `device_id`, aunque se borre
///    el almacenamiento de la app (reinstalación de desarrollo o del usuario).
///  - NO viaja PII de hardware en crudo: lo que sale es un UUID derivado
///    (hash de namespace), coherente con la minimización de datos (DA-02).
///  - Si no hay identificador de hardware (otra plataforma / no disponible), se
///    cae a un UUID aleatorio persistido (comportamiento anterior).
///
/// Las instalaciones existentes **no cambian**: si ya hay un id guardado, se
/// respeta (no se re-deriva), para no romper el vínculo con el servidor.
class DeviceIdStore {
  DeviceIdStore(
    this._storage, {
    this.hardwareId = const HardwareIdSource(),
  });

  final FlutterSecureStorage _storage;

  /// Fuente del identificador de hardware estable (inyectable en tests).
  final HardwareIdSource hardwareId;

  static const _key = 'device_id_v1';

  /// Namespace fijo (UUID válido) para derivar el device_id del hardware
  /// (UUID v5). No es secreto; solo fija un espacio de nombres propio y estable.
  static const _namespace = '7f02017f-81e3-4200-a32e-d6d1a9f2dde1';

  /// Devuelve el device_id existente; si no hay, lo deriva del hardware estable
  /// (UUID v5 de `ANDROID_ID`) y, en último caso, genera uno aleatorio. Persiste
  /// el resultado para lecturas posteriores sin tocar la capa nativa.
  Future<String> getOrCreate() async {
    final existing = await _storage.read(
      key: _key,
      aOptions: secureAndroidOptions,
    );
    if (existing != null && existing.isNotEmpty) return existing;

    final id = await _deriveId();
    await _storage.write(key: _key, value: id, aOptions: secureAndroidOptions);
    return id;
  }

  /// Lee el device_id si existe (sin crearlo).
  Future<String?> read() =>
      _storage.read(key: _key, aOptions: secureAndroidOptions);

  Future<String> _deriveId() async {
    final hw = await hardwareId.stableHardwareId();
    if (hw != null) {
      // UUID v5 determinista: mismo hardware → mismo device_id entre reinstalaciones.
      return const Uuid().v5(_namespace, hw);
    }
    // Sin identificador de hardware: UUID aleatorio (fallback histórico).
    return const Uuid().v4();
  }
}
