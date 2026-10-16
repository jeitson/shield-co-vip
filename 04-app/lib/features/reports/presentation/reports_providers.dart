import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/config/config_providers.dart';
import 'package:shield_app/core/network/api_client.dart';
import 'package:shield_app/features/device/presentation/device_providers.dart';
import 'package:shield_app/features/reports/data/reports_remote_data_source.dart';
import 'package:shield_app/features/reports/data/reports_remote_data_source_api.dart';
import 'package:shield_app/features/reports/data/reports_remote_data_source_fake.dart';
import 'package:shield_app/features/reports/data/reports_repository_impl.dart';
import 'package:shield_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:shield_app/features/reports/domain/usecases/submit_report.dart';
import 'package:shield_app/features/reports/domain/usecases/was_reported_by_me.dart';

/// Fuente remota del reporte comunitario, elegida por configuración de entorno.
///
/// - Con credenciales de Supabase (`AppConfig.hasSupabase`): implementación
///   **real** contra `v1-report`, por el Dio autenticado con `x-device-id`
///   (`deviceAwareDioProvider`).
/// - Sin ellas (tests / offline): implementación **fake** en memoria.
///   Dominio y presentación no cambian en ningún caso (patrón de `auth`).
final reportsRemoteDataSourceProvider = Provider<ReportsRemoteDataSource>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.hasSupabase) {
    return ReportsRemoteDataSourceApi(
      ApiClient(ref.watch(deviceAwareDioProvider)),
      ref.watch(deviceIdStoreProvider),
    );
  }
  return ReportsRemoteDataSourceFake();
});

/// Repositorio de reportes (compone la fuente remota).
final reportsRepositoryProvider = Provider<ReportsRepository>(
  (ref) => ReportsRepositoryImpl(ref.watch(reportsRemoteDataSourceProvider)),
);

/// Caso de uso de envío de reporte.
final submitReportProvider = Provider<SubmitReport>(
  (ref) => SubmitReport(ref.watch(reportsRepositoryProvider)),
);

/// Caso de uso de consulta "¿ya lo reporté?".
final wasReportedByMeProvider = Provider<WasReportedByMe>(
  (ref) => WasReportedByMe(ref.watch(reportsRepositoryProvider)),
);

/// Estado "ya reportado" por número (R9), consultado al servidor. `false`
/// mientras carga o si la consulta falla (no bloquea la UI). El detalle lo usa
/// para sembrar el controller al abrir; se invalida tras reportar.
final reportedStatusProvider = FutureProvider.family<bool, String>((
  ref,
  numero,
) async {
  final result = await ref.watch(wasReportedByMeProvider).call(numero);
  return result.fold((v) => v, (_) => false);
});
