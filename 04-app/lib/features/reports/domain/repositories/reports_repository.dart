import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/reports/domain/entities/community_report.dart';
import 'package:shield_app/features/reports/domain/entities/report_outcome.dart';

/// Contrato del reporte comunitario anónimo (spec 04, DA-10).
///
/// El **bloqueo local** NO es parte de este contrato: lo realiza la feature
/// `lists` (exclusividad RN-05 + reproyección al motor). Aquí solo viaja el
/// reporte al backend (`POST /v1/report`).
abstract interface class ReportsRepository {
  /// Envía el reporte comunitario. Devuelve el [ReportOutcome] en éxito, o un
  /// [Failure] (reintentable) ante error de red/servidor.
  Future<Result<ReportOutcome>> report(CommunityReport report);

  /// Consulta si este dispositivo ya reportó [numero] (R9). `true` si sí.
  Future<Result<bool>> wasReportedByMe(String numero);
}
