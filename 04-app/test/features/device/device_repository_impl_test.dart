import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/device/data/device_id_store.dart';
import 'package:shield_app/features/device/data/device_repository_impl.dart';
import 'package:shield_app/features/device/data/session_remote_data_source.dart';
import 'package:shield_app/features/device/domain/device_info.dart';
import 'package:shield_app/features/device/domain/device_repository.dart';

/// Secure storage en memoria.
class _MemStorage implements FlutterSecureStorage {
  final Map<String, String> _m = {};
  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _m[key];
  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => value == null ? _m.remove(key) : _m[key] = value;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// Data source falso configurable.
class _FakeRemote implements SessionRemoteDataSource {
  Result<Map<String, dynamic>> registerResult = const Ok({'estado': 'activo'});
  Result<Map<String, dynamic>> activateResult = const Ok({'estado': 'activo'});
  Result<DeviceSessionStatus> refreshResult = const Ok(
    DeviceSessionStatus.activo,
  );

  @override
  Future<Result<Map<String, dynamic>>> register({
    required String deviceId,
    required DeviceInfo info,
    required String numeroProtegido,
  }) async => registerResult;

  @override
  Future<Result<Map<String, dynamic>>> activate({
    required String deviceId,
    required String numeroProtegido,
  }) async => activateResult;

  @override
  Future<Result<DeviceSessionStatus>> refresh({
    required String deviceId,
  }) async => refreshResult;
}

const _info = DeviceInfo(
  marca: 'Motorola',
  modelo: 'moto g04s',
  so: 'android',
  soVersion: '14',
  appVersion: '1.0.0',
  idioma: 'es-CO',
  zonaHoraria: 'America/Bogota',
);

void main() {
  late _FakeRemote remote;
  late DeviceRepositoryImpl repo;

  setUp(() {
    remote = _FakeRemote();
    repo = DeviceRepositoryImpl(
      remote: remote,
      deviceIdStore: DeviceIdStore(_MemStorage()),
      deviceInfo: _info,
    );
  });

  group('registerThisDevice', () {
    test('estado activo → DeviceRegistrationStatus.activo', () async {
      remote.registerResult = const Ok({'estado': 'activo'});
      final r = await repo.registerThisDevice(numeroProtegido: '+573001112233');
      expect(r.isOk, isTrue);
      r.fold(
        (s) => expect(s, DeviceRegistrationStatus.activo),
        (_) => fail('ok'),
      );
    });

    test('pendiente_confirmacion → status pendiente (exclusividad)', () async {
      remote.registerResult = const Ok({
        'estado': 'pendiente_confirmacion',
        'warning': 'numero_protegido_en_otro_dispositivo',
      });
      final r = await repo.registerThisDevice(numeroProtegido: '+573001112233');
      r.fold(
        (s) => expect(s, DeviceRegistrationStatus.pendienteConfirmacion),
        (_) => fail('ok'),
      );
    });
  });

  group('refresh', () {
    test('activo → DeviceSessionStatus.activo', () async {
      remote.refreshResult = const Ok(DeviceSessionStatus.activo);
      final r = await repo.refresh();
      r.fold((s) => expect(s, DeviceSessionStatus.activo), (_) => fail('ok'));
    });

    test('revocado explícito → DeviceRevokedFailure (dispara wipe)', () async {
      remote.refreshResult = const Err(DeviceRevokedFailure());
      final r = await repo.refresh();
      expect(r.isErr, isTrue);
      r.fold(
        (_) => fail('debía ser error de revocación'),
        (f) => expect(f, isA<DeviceRevokedFailure>()),
      );
    });

    test('no registrado → noRegistrado (no borra material)', () async {
      remote.refreshResult = const Ok(DeviceSessionStatus.noRegistrado);
      final r = await repo.refresh();
      r.fold(
        (s) => expect(s, DeviceSessionStatus.noRegistrado),
        (_) => fail('ok'),
      );
    });

    test('error de red se propaga (no se trata como revocado)', () async {
      remote.refreshResult = const Err(NetworkFailure());
      final r = await repo.refresh();
      expect(r.isErr, isTrue);
    });
  });
}
