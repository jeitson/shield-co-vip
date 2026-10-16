import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/reports/domain/entities/community_report.dart';
import 'package:shield_app/features/reports/domain/entities/report_outcome.dart';
import 'package:shield_app/features/reports/domain/repositories/reports_repository.dart';

/// Caso de uso: enviar un reporte comunitario anónimo.
///
/// Valida mínimamente (número no vacío) y delega en el repositorio. La
/// orquestación "bloqueo local primero, reporte después" vive en el controller
/// de presentación (spec 04 §6), para que el bloqueo se conserve aunque el
/// reporte falle (R8.2).
class SubmitReport {
  const SubmitReport(this._repository);

  final ReportsRepository _repository;

  Future<Result<ReportOutcome>> call(CommunityReport report) {
    if (report.numero.trim().isEmpty) {
      return Future.value(const Err(ServerFailure('Número inválido')));
    }
    return _repository.report(report);
  }
}
