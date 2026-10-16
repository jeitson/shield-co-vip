import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/device/data/device_id_store.dart';
import 'package:shield_app/features/device/data/session_remote_data_source.dart';
import 'package:shield_app/features/device/domain/device_info.dart';
import 'package:shield_app/features/device/domain/device_repository.dart';

/// Implementación de [DeviceRepository] sobre `v1-session`.
class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl({
    required this.remote,
    required this.deviceIdStore,
    required this.deviceInfo,
  });

  final SessionRemoteDataSource remote;
  final DeviceIdStore deviceIdStore;
  final DeviceInfo deviceInfo;

  @override
  Future<Result<DeviceRegistrationStatus>> registerThisDevice({
    required String numeroProtegido,
  }) async {
    final deviceId = await deviceIdStore.getOrCreate();
    final result = await remote.register(
      deviceId: deviceId,
      info: deviceInfo,
      numeroProtegido: numeroProtegido,
    );
    return result.map((json) {
      final estado = json['estado'] as String?;
      return estado == 'pendiente_confirmacion'
          ? DeviceRegistrationStatus.pendienteConfirmacion
          : DeviceRegistrationStatus.activo;
    });
  }

  @override
  Future<Result<void>> confirmExclusivity({
    required String numeroProtegido,
  }) async {
    final deviceId = await deviceIdStore.getOrCreate();
    final result = await remote.activate(
      deviceId: deviceId,
      numeroProtegido: numeroProtegido,
    );
    return result.map((_) {});
  }

  @override
  Future<Result<DeviceSessionStatus>> refresh() async {
    final deviceId = await deviceIdStore.getOrCreate();
    // El data source ya distingue activo / revocado (DeviceRevokedFailure) /
    // noRegistrado / error recuperable, sin borrar por 401 transitorios.
    return remote.refresh(deviceId: deviceId);
  }
}
