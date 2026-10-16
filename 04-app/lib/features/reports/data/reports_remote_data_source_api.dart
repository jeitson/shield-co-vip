import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/core/network/api_client.dart';
import 'package:shield_app/features/device/data/device_id_store.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/reports/data/reports_remote_data_source.dart';
import 'package:shield_app/features/reports/domain/entities/report_outcome.dart';

/// Implementación **real** del reporte comunitario contra la Edge Function
/// `v1-report` (DA-10), vía el [ApiClient] autenticado con `x-device-id`.
///
/// Envía solo `{ numero, categoria, device_id_anon }` (RN-DETAIL-02): el
/// servidor normaliza a E.164, calcula el HMAC con el pepper y guarda el reporte
/// en estado `pendiente`. El `device_id_anon` del cuerpo es informativo; el
/// servidor confía en el header `x-device-id` validado.
class ReportsRemoteDataSourceApi implements ReportsRemoteDataSource {
  ReportsRemoteDataSourceApi(this._client, this._deviceIdStore);

  final ApiClient _client;
  final DeviceIdStore _deviceIdStore;

  @override
  Future<Result<ReportOutcome>> report({
    required String numero,
    required ThreatCategory categoria,
  }) async {
    final deviceId = await _deviceIdStore.getOrCreate();

    // postRaw: necesitamos distinguir desenlaces por el cuerpo (pendiente /
    // ya_reportado / rechazado) sin que un 4xx se convierta en excepción.
    final res = await _client.postRaw(
      'v1-report',
      data: {
        'numero': numero,
        // Label estable del catálogo RN-07 (mismo literal que el servidor/seed).
        'categoria': categoria.label,
        'device_id_anon': deviceId,
      },
    );

    final status = res.status;
    final body = res.body;

    // Sin respuesta (red) o error de servidor → reintentable (R8.1).
    if (status == null) {
      return const Err(NetworkFailure());
    }

    final estado = (body is Map) ? body['estado'] as String? : null;

    switch (estado) {
      case 'pendiente':
        return const Ok(ReportOutcome.pendiente);
      case 'ya_reportado':
        return const Ok(ReportOutcome.yaReportado);
      case 'rechazado':
        final motivo = (body is Map) ? body['motivo'] as String? : null;
        if (motivo == 'numero_protegido') {
          return const Ok(ReportOutcome.rechazadoProtegido);
        }
        return Err(ServerFailure('Reporte rechazado', statusCode: status));
      default:
        // 4xx/5xx sin estado reconocido → error reintentable.
        return Err(
          ServerFailure('No se pudo enviar el reporte', statusCode: status),
        );
    }
  }

  @override
  Future<Result<bool>> wasReportedByMe(String numero) async {
    final res = await _client.get<Map<String, dynamic>>(
      'v1-report',
      queryParameters: {'numero': numero},
    );
    return res.fold(
      (body) => Ok(body['reportado'] == true),
      (failure) => Err(failure),
    );
  }
}
