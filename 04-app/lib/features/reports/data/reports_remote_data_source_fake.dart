import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/reports/data/reports_remote_data_source.dart';
import 'package:shield_app/features/reports/domain/entities/report_outcome.dart';

/// Implementación **fake** del reporte comunitario (tests / desarrollo offline).
///
/// Reproduce la dedup del servidor (DA-10): el primer reporte de un número
/// devuelve `pendiente`; repetirlo devuelve `yaReportado`. No hay red; permite
/// validar toda la UI del detalle sin backend desplegado.
class ReportsRemoteDataSourceFake implements ReportsRemoteDataSource {
  final Set<String> _reported = {};

  @override
  Future<Result<ReportOutcome>> report({
    required String numero,
    required ThreatCategory categoria,
  }) async {
    final isNew = _reported.add(numero);
    return Ok(isNew ? ReportOutcome.pendiente : ReportOutcome.yaReportado);
  }

  @override
  Future<Result<bool>> wasReportedByMe(String numero) async {
    return Ok(_reported.contains(numero));
  }
}
