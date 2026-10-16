import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/reports/data/reports_remote_data_source_fake.dart';
import 'package:shield_app/features/reports/data/reports_repository_impl.dart';
import 'package:shield_app/features/reports/domain/entities/community_report.dart';
import 'package:shield_app/features/reports/domain/entities/report_outcome.dart';
import 'package:shield_app/features/reports/domain/usecases/submit_report.dart';

void main() {
  group('ReportsRemoteDataSourceFake (idempotencia local, R9)', () {
    test('primer reporte → pendiente; repetido → yaReportado', () async {
      final fake = ReportsRemoteDataSourceFake();

      final first = await fake.report(
        numero: '+573001234567',
        categoria: ThreatCategory.extorsion,
      );
      final second = await fake.report(
        numero: '+573001234567',
        categoria: ThreatCategory.extorsion,
      );

      expect((first as Ok).value, ReportOutcome.pendiente);
      expect((second as Ok).value, ReportOutcome.yaReportado);
    });

    test('números distintos son reportes independientes', () async {
      final fake = ReportsRemoteDataSourceFake();
      final a = await fake.report(
        numero: '+573001111111',
        categoria: ThreatCategory.phishing,
      );
      final b = await fake.report(
        numero: '+573002222222',
        categoria: ThreatCategory.phishing,
      );
      expect((a as Ok).value, ReportOutcome.pendiente);
      expect((b as Ok).value, ReportOutcome.pendiente);
    });

    test('wasReportedByMe refleja si el número ya fue reportado (R9)', () async {
      final fake = ReportsRemoteDataSourceFake();
      final before = await fake.wasReportedByMe('+573001234567');
      expect((before as Ok).value, isFalse);

      await fake.report(
        numero: '+573001234567',
        categoria: ThreatCategory.extorsion,
      );

      final after = await fake.wasReportedByMe('+573001234567');
      expect((after as Ok).value, isTrue);
    });
  });

  group('SubmitReport', () {
    test('número vacío → Err sin tocar el repositorio', () async {
      final repo = ReportsRepositoryImpl(ReportsRemoteDataSourceFake());
      final usecase = SubmitReport(repo);

      final result = await usecase(
        const CommunityReport(numero: '  ', categoria: ThreatCategory.extorsion),
      );

      expect(result.isErr, isTrue);
    });

    test('número válido delega y devuelve el desenlace', () async {
      final repo = ReportsRepositoryImpl(ReportsRemoteDataSourceFake());
      final usecase = SubmitReport(repo);

      final result = await usecase(
        const CommunityReport(
          numero: '+573001234567',
          categoria: ThreatCategory.callcenter,
        ),
      );

      expect((result as Ok).value, ReportOutcome.pendiente);
    });
  });
}
