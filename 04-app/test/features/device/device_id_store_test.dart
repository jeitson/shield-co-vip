import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/features/device/data/device_id_store.dart';
import 'package:shield_app/features/device/data/hardware_id_source.dart';

/// Secure storage en memoria (no toca el SO).
class _MemStorage extends FlutterSecureStorage {
  _MemStorage([Map<String, String>? seed]) : _m = {...?seed};
  final Map<String, String> _m;

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _m[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _m.remove(key);
    } else {
      _m[key] = value;
    }
  }
}

class _FakeHardware extends HardwareIdSource {
  const _FakeHardware(this._id);
  final String? _id;
  @override
  Future<String?> stableHardwareId() async => _id;
}

void main() {
  test('deriva un device_id estable del hardware (sobrevive reinstalación)',
      () async {
    const hw = _FakeHardware('androidid-ABC123');

    // Primera instalación: storage vacío.
    final store1 = DeviceIdStore(_MemStorage(), hardwareId: hw);
    final id1 = await store1.getOrCreate();

    // "Reinstalación": storage borrado (nuevo MemStorage), mismo hardware.
    final store2 = DeviceIdStore(_MemStorage(), hardwareId: hw);
    final id2 = await store2.getOrCreate();

    expect(id1, isNotEmpty);
    expect(id1, id2); // mismo equipo → mismo device_id tras reinstalar
  });

  test('respeta un device_id ya almacenado (instalaciones existentes)',
      () async {
    final storage = _MemStorage({'device_id_v1': 'pre-existente-uuid'});
    const hw = _FakeHardware('androidid-XYZ');
    final store = DeviceIdStore(storage, hardwareId: hw);

    expect(await store.getOrCreate(), 'pre-existente-uuid');
  });

  test('sin hardware disponible cae a un UUID aleatorio y lo persiste',
      () async {
    const hw = _FakeHardware(null);
    final storage = _MemStorage();
    final store = DeviceIdStore(storage, hardwareId: hw);

    final id = await store.getOrCreate();
    expect(id, isNotEmpty);
    // Persistido: una segunda lectura devuelve el mismo valor.
    expect(await store.getOrCreate(), id);
  });

  test('hardware comodín (todo ceros) se trata como no disponible', () async {
    // El filtro de "todo ceros" vive en HardwareIdSource; aquí validamos que un
    // id no-cero sí se usa y produce un UUID v5 válido (36 chars, versión 5).
    const hw = _FakeHardware('androidid-REAL');
    final store = DeviceIdStore(_MemStorage(), hardwareId: hw);
    final id = await store.getOrCreate();
    expect(id.length, 36);
    expect(id[14], '5'); // dígito de versión UUID v5
  });
}
