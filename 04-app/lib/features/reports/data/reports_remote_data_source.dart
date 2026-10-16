import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/reports/domain/entities/report_outcome.dart';

/// Fuente remota del reporte comunitario. Dos implementaciones: real (Edge
/// Function `v1-report`) y fake (en memoria), elegidas por configuración de
/// entorno (`AppConfig.hasSupabase`), igual que `auth`/`device`.
abstract interface class ReportsRemoteDataSource {
  Future<Result<ReportOutcome>> report({
    required String numero,
    required ThreatCategory categoria,
  });

  /// Consulta si ESTE dispositivo ya reportó [numero] (R9, fuente de verdad en
  /// el servidor). `true` si ya existe un reporte propio del número.
  Future<Result<bool>> wasReportedByMe(String numero);
}
