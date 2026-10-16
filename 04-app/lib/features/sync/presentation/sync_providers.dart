import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/config/config_providers.dart';
import 'package:shield_app/core/db/db_providers.dart';
import 'package:shield_app/core/network/api_client.dart';
import 'package:shield_app/core/network/app_version_interceptor.dart';
import 'package:shield_app/core/network/network_providers.dart';
import 'package:shield_app/core/network/supabase_auth_interceptor.dart';
import 'package:shield_app/core/secure/pepper_store.dart';
import 'package:shield_app/core/secure/secure_providers.dart';
import 'package:shield_app/features/device/data/device_id_store.dart';
import 'package:shield_app/features/sync/data/datasources/sync_metadata_store.dart';
import 'package:shield_app/features/sync/data/datasources/sync_remote_data_source.dart';
import 'package:shield_app/features/sync/data/repositories/dataset_repository_impl.dart';
import 'package:shield_app/features/sync/data/repositories/pepper_repository_impl.dart';
import 'package:shield_app/features/sync/domain/repositories/dataset_repository.dart';
import 'package:shield_app/features/sync/domain/repositories/pepper_repository.dart';
import 'package:shield_app/features/sync/domain/usecases/sync_dataset.dart';

// --- Red del sync (Dio autenticado por Supabase) ---

/// Dio dedicado al sync: apunta a `…/functions/v1`, con el interceptor de
/// versión (DA-15) y el de auth de Supabase (Bearer JWT + apikey).
final _syncDioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.versionedApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(AppVersionInterceptor(kAppVersion));
  // Incluir `x-device-id` para que v1-sync/v1-pepper verifiquen dispositivo
  // activo (DA-02/03/04). El store crea/lee el UUID de instalación.
  final deviceStore = DeviceIdStore(ref.watch(secureStorageProvider));
  dio.interceptors.add(
    SupabaseAuthInterceptor(config.supabaseAnonKey, deviceId: deviceStore.read),
  );
  if (config.enableLogging) {
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }
  return dio;
});

final _syncApiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(_syncDioProvider)),
);

final _syncRemoteDataSourceProvider = Provider<SyncRemoteDataSource>(
  (ref) => SyncRemoteDataSource(ref.watch(_syncApiClientProvider)),
);

// --- Stores ---

final pepperStoreProvider = Provider<PepperStore>(
  (ref) => PepperStore(ref.watch(secureStorageProvider)),
);

final _syncMetadataStoreProvider = Provider<SyncMetadataStore>(
  (ref) => SyncMetadataStore(ref.watch(secureStorageProvider)),
);

// --- Repositorios ---

final pepperRepositoryProvider = Provider<PepperRepository>(
  (ref) => PepperRepositoryImpl(
    remote: ref.watch(_syncRemoteDataSourceProvider),
    store: ref.watch(pepperStoreProvider),
  ),
);

/// Repositorio del dataset. Depende de la base local (asíncrona), por eso es un
/// `FutureProvider`.
final datasetRepositoryProvider = FutureProvider<DatasetRepository>((
  ref,
) async {
  final dao = await ref.watch(phoneHashesDaoProvider.future);
  return DatasetRepositoryImpl(
    remote: ref.watch(_syncRemoteDataSourceProvider),
    dao: dao,
    metadata: ref.watch(_syncMetadataStoreProvider),
    pepper: ref.watch(pepperRepositoryProvider),
  );
});

final syncDatasetUseCaseProvider = FutureProvider<SyncDataset>((ref) async {
  final repo = await ref.watch(datasetRepositoryProvider.future);
  return SyncDataset(repo);
});

// --- Estado observable para la UI ---

/// Conteo reactivo de firmas activas de la lista local (RF-SHIELD-06).
final datasetCountProvider = StreamProvider<int>((ref) async* {
  final repo = await ref.watch(datasetRepositoryProvider.future);
  yield* repo.watchCountActive();
});
