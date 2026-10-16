import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/reports/data/reports_remote_data_source.dart';
import 'package:shield_app/features/reports/domain/entities/community_report.dart';
import 'package:shield_app/features/reports/domain/entities/report_outcome.dart';
import 'package:shield_app/features/reports/domain/repositories/reports_repository.dart';

/// Implementación del repositorio de reportes sobre la fuente remota (real/fake).
class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._remote);

  final ReportsRemoteDataSource _remote;

  @override
  Future<Result<ReportOutcome>> report(CommunityReport report) {
    return _remote.report(
      numero: report.numero,
      categoria: report.categoria,
    );
  }

  @override
  Future<Result<bool>> wasReportedByMe(String numero) {
    return _remote.wasReportedByMe(numero);
  }
}
