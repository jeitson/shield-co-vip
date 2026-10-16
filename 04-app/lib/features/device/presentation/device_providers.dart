import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/config/config_providers.dart';
import 'package:shield_app/core/db/db_providers.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/network/api_client.dart';
import 'package:shield_app/core/network/app_version_interceptor.dart';
import 'package:shield_app/core/network/network_providers.dart';
import 'package:shield_app/core/network/supabase_auth_interceptor.dart';
import 'package:shield_app/core/secure/local_crypto_keys.dart';
import 'package:shield_app/core/secure/secure_providers.dart';
import 'package:shield_app/features/device/data/device_id_store.dart';
import 'package:shield_app/features/device/data/device_info_loader.dart';
import 'package:shield_app/features/device/data/device_repository_impl.dart';
import 'package:shield_app/features/device/data/session_remote_data_source.dart';
import 'package:shield_app/features/device/data/session_wiper.dart';
import 'package:shield_app/features/device/domain/device_repository.dart';
import 'package:shield_app/features/sync/presentation/sync_providers.dart';

/// Store del device_id de instalación (DA-02).
final deviceIdStoreProvider = Provider<DeviceIdStore>(
  (ref) => DeviceIdStore(ref.watch(secureStorageProvider)),
);

/// Dio autenticado **con `x-device-id`** para las Edge Functions que exigen
/// dispositivo activo (session/sync/pepper). El header lo resuelve el store.
final deviceAwareDioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final store = ref.watch(deviceIdStoreProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.versionedApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(AppVersionInterceptor(kAppVersion));
  dio.interceptors.add(
    SupabaseAuthInterceptor(config.supabaseAnonKey, deviceId: store.read),
  );
  if (config.enableLogging) {
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }
  return dio;
});

final _sessionRemoteDataSourceProvider = Provider<SessionRemoteDataSource>(
  (ref) =>
      SessionRemoteDataSource(ApiClient(ref.watch(deviceAwareDioProvider))),
);

/// Repositorio de dispositivo. Carga los metadatos de forma perezosa.
final deviceRepositoryProvider = FutureProvider<DeviceRepository>((ref) async {
  final info = await DeviceInfoLoader.load();
  return DeviceRepositoryImpl(
    remote: ref.watch(_sessionRemoteDataSourceProvider),
    deviceIdStore: ref.watch(deviceIdStoreProvider),
    deviceInfo: info,
  );
});

/// Borrado de material sensible en revocación (DA-04).
final sessionWiperProvider = FutureProvider<SessionWiper>((ref) async {
  final phoneDao = await ref.watch(phoneHashesDaoProvider.future);
  return SessionWiper(
    pepperStore: ref.watch(pepperStoreProvider),
    cryptoKeys: LocalCryptoKeys(ref.watch(secureStorageProvider)),
    phoneHashesDao: phoneDao,
  );
});

/// Resultado de registrar el dispositivo tras el login.
enum DeviceRegisterOutcome { activo, requiereConfirmacion, error }

/// Coordina el registro del dispositivo post-login y el refresh con wipe.
final deviceSessionControllerProvider = Provider<DeviceSessionController>(
  (ref) => DeviceSessionController(ref),
);

class DeviceSessionController {
  DeviceSessionController(this._ref);
  final Ref _ref;

  /// Registra este dispositivo con el número del perfil. Devuelve el resultado
  /// para que la UI muestre el diálogo de exclusividad si procede (R7).
  Future<DeviceRegisterOutcome> register(String numeroProtegido) async {
    if (numeroProtegido.isEmpty) return DeviceRegisterOutcome.activo;
    final repo = await _ref.read(deviceRepositoryProvider.future);
    final result = await repo.registerThisDevice(
      numeroProtegido: numeroProtegido,
    );
    return result.fold(
      (status) => status == DeviceRegistrationStatus.pendienteConfirmacion
          ? DeviceRegisterOutcome.requiereConfirmacion
          : DeviceRegisterOutcome.activo,
      (_) => DeviceRegisterOutcome.error,
    );
  }

  /// Confirma la exclusividad (revoca el anterior, activa este).
  Future<bool> confirmExclusivity(String numeroProtegido) async {
    final repo = await _ref.read(deviceRepositoryProvider.future);
    final result = await repo.confirmExclusivity(
      numeroProtegido: numeroProtegido,
    );
    return result.isOk;
  }

  /// Verifica la sesión de dispositivo. Solo si el servidor confirma
  /// **revocación explícita** (`DeviceRevokedFailure`, DA-04) borra el material
  /// sensible y devuelve `true`. Un 401 transitorio, un "no registrado" o un
  /// error de red **no** borran nada (devuelve `false`).
  Future<bool> refreshAndWipeIfRevoked() async {
    final repo = await _ref.read(deviceRepositoryProvider.future);
    final result = await repo.refresh();
    final revoked = result.fold(
      (_) => false,
      (failure) => failure is DeviceRevokedFailure,
    );
    if (revoked) {
      final wiper = await _ref.read(sessionWiperProvider.future);
      await wiper.wipe();
    }
    return revoked;
  }
}
