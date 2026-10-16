import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shield_app/core/config/app_config.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/db/encrypted_database.dart';
import 'package:shield_app/core/network/api_client.dart';
import 'package:shield_app/core/network/app_version_interceptor.dart';
import 'package:shield_app/core/network/network_providers.dart';
import 'package:shield_app/core/network/supabase_auth_interceptor.dart';
import 'package:shield_app/core/secure/local_crypto_keys.dart';
import 'package:shield_app/core/secure/pepper_store.dart';
import 'package:shield_app/features/device/data/device_id_store.dart';
import 'package:shield_app/features/sync/data/datasources/sync_metadata_store.dart';
import 'package:shield_app/features/sync/data/datasources/sync_remote_data_source.dart';
import 'package:shield_app/features/sync/data/repositories/dataset_repository_impl.dart';
import 'package:shield_app/features/sync/data/repositories/pepper_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

/// Nombre único de la tarea periódica de sync en background (`03-datos` §03.4).
const kDailySyncTask = 'cifrado_cero_daily_sync';

/// Registra la sincronización diaria en background con WorkManager (Android).
/// Se llama en el arranque si hay backend configurado. iOS queda diferido.
Future<void> registerBackgroundSync() async {
  await Workmanager().initialize(syncCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    kDailySyncTask,
    kDailySyncTask,
    frequency: const Duration(hours: 24),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

/// Punto de entrada del isolate de background. No hay árbol de Riverpod aquí,
/// así que se arman las dependencias a mano (misma composición que los
/// providers). Debe ser una función top-level anotada con `@pragma`.
@pragma('vm:entry-point')
void syncCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != kDailySyncTask) return true;
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final config = AppConfig.resolveFromEnvironment();
      if (!config.hasSupabase) return true; // sin backend, nada que sincronizar

      await Supabase.initialize(
        url: config.supabaseUrl,
        publishableKey: config.supabaseAnonKey,
      );
      // Sin sesión persistida no se puede sincronizar (requiere JWT).
      if (Supabase.instance.client.auth.currentSession == null) return true;

      const storage = FlutterSecureStorage();

      // Base cifrada.
      final dek = await LocalCryptoKeys(storage).getOrCreateDek();
      final db = AppDatabase(openEncryptedDatabase(dek));

      // Red autenticada.
      final dio =
          Dio(
              BaseOptions(
                baseUrl: config.versionedApiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                headers: {'Content-Type': 'application/json'},
              ),
            )
            ..interceptors.addAll([
              AppVersionInterceptor(kAppVersion),
              SupabaseAuthInterceptor(
                config.supabaseAnonKey,
                deviceId: DeviceIdStore(storage).read,
              ),
            ]);
      final remote = SyncRemoteDataSource(ApiClient(dio));

      final pepper = PepperRepositoryImpl(
        remote: remote,
        store: PepperStore(storage),
      );
      final repo = DatasetRepositoryImpl(
        remote: remote,
        dao: db.phoneHashesDao,
        metadata: SyncMetadataStore(storage),
        pepper: pepper,
      );

      await repo.syncNow();
      await db.close();
      return true;
    } catch (_) {
      // Fallo silencioso: WorkManager reintentará en el próximo ciclo.
      return false;
    }
  });
}
