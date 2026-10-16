import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/events/presentation/controllers/detail_action_controller.dart';
import 'package:shield_app/features/events/presentation/state/detail_action_state.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/domain/repositories/lists_repository.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';
import 'package:shield_app/features/reports/domain/entities/community_report.dart';
import 'package:shield_app/features/reports/domain/entities/report_outcome.dart';
import 'package:shield_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:shield_app/features/reports/presentation/reports_providers.dart';

class _FakeListsRepository implements ListsRepository {
  final Map<String, ListKind> store = {};
  bool failClassify = false;

  @override
  Future<Result<void>> classify({
    required String numero,
    required ListKind? kind,
    ListOrigin origin = ListOrigin.evento,
  }) async {
    if (failClassify) return const Err(UnknownFailure());
    if (kind == null) {
      store.remove(numero);
    } else {
      store[numero] = kind;
    }
    return const Ok(null);
  }

  @override
  Stream<ListKind?> watchMembership(String numero) => Stream.value(store[numero]);
  @override
  Stream<Set<String>> watchConfianza() => Stream.value(const {});
  @override
  Stream<Set<String>> watchNegra() => Stream.value(store.keys.toSet());
}

class _FakeReportsRepository implements ReportsRepository {
  _FakeReportsRepository(this._result);
  final Result<ReportOutcome> _result;
  int calls = 0;
  CommunityReport? lastReport;

  @override
  Future<Result<ReportOutcome>> report(CommunityReport report) async {
    calls++;
    lastReport = report;
    return _result;
  }

  @override
  Future<Result<bool>> wasReportedByMe(String numero) async => const Ok(false);
}

ProviderContainer _container(
  _FakeListsRepository lists,
  _FakeReportsRepository reports,
) {
  return ProviderContainer(
    overrides: [
      listsRepositoryProvider.overrideWith((ref) async => lists),
      reportsRepositoryProvider.overrideWithValue(reports),
    ],
  );
}

const _sender = '+573001234567';

void main() {
  test('reportAndBlock bloquea primero y reporta después (éxito)', () async {
    final lists = _FakeListsRepository();
    final reports = _FakeReportsRepository(const Ok(ReportOutcome.pendiente));
    final container = _container(lists, reports);
    addTearDown(container.dispose);

    final notifier =
        container.read(detailActionControllerProvider(_sender).notifier);
    await notifier.reportAndBlock(ThreatCategory.extorsion);

    final state = container.read(detailActionControllerProvider(_sender));
    expect(lists.store[_sender], ListKind.negra); // bloqueado localmente
    expect(reports.calls, 1);
    expect(reports.lastReport?.numero, _sender);
    expect(state.phase, DetailActionPhase.success);
    expect(state.outcome, ReportOutcome.pendiente);
    expect(state.localBlockDone, isTrue);
  });

  test('si el reporte falla, el bloqueo local se conserva y queda reintentable',
      () async {
    final lists = _FakeListsRepository();
    final reports = _FakeReportsRepository(const Err(NetworkFailure()));
    final container = _container(lists, reports);
    addTearDown(container.dispose);

    final notifier =
        container.read(detailActionControllerProvider(_sender).notifier);
    await notifier.reportAndBlock(ThreatCategory.phishing);

    final state = container.read(detailActionControllerProvider(_sender));
    expect(lists.store[_sender], ListKind.negra); // bloqueo conservado (R8.2)
    expect(state.phase, DetailActionPhase.error);
    expect(state.localBlockDone, isTrue);
    expect(state.errorMessage, isNotNull);
  });

  test('retryReport re-envía el reporte sin volver a bloquear', () async {
    final lists = _FakeListsRepository();
    final reports = _FakeReportsRepository(const Ok(ReportOutcome.pendiente));
    final container = _container(lists, reports);
    addTearDown(container.dispose);

    final notifier =
        container.read(detailActionControllerProvider(_sender).notifier);
    await notifier.retryReport(ThreatCategory.extorsion);

    // retryReport no toca el bloqueo local.
    expect(lists.store.containsKey(_sender), isFalse);
    expect(reports.calls, 1);
  });

  test('blockLocal bloquea sin reportar', () async {
    final lists = _FakeListsRepository();
    final reports = _FakeReportsRepository(const Ok(ReportOutcome.pendiente));
    final container = _container(lists, reports);
    addTearDown(container.dispose);

    final notifier =
        container.read(detailActionControllerProvider(_sender).notifier);
    await notifier.blockLocal();

    final state = container.read(detailActionControllerProvider(_sender));
    expect(lists.store[_sender], ListKind.negra);
    expect(reports.calls, 0); // no reporte
    expect(state.localBlockDone, isTrue);
    expect(state.phase, DetailActionPhase.success);
  });

  test('seedAlreadyReported refleja "ya reportado" sin disparar acciones', () async {
    final lists = _FakeListsRepository();
    final reports = _FakeReportsRepository(const Ok(ReportOutcome.pendiente));
    final container = _container(lists, reports);
    addTearDown(container.dispose);

    final notifier =
        container.read(detailActionControllerProvider(_sender).notifier);
    notifier.seedAlreadyReported();

    final state = container.read(detailActionControllerProvider(_sender));
    expect(state.kind, DetailActionKind.dualReport);
    expect(state.phase, DetailActionPhase.success);
    expect(state.outcome, ReportOutcome.yaReportado);
    expect(state.localBlockDone, isTrue);
    // No reportó ni bloqueó: solo refleja el estado del servidor.
    expect(reports.calls, 0);
    expect(lists.store.containsKey(_sender), isFalse);
  });

  test('rechazadoProtegido es éxito (no error) y mantiene el bloqueo', () async {
    final lists = _FakeListsRepository();
    final reports =
        _FakeReportsRepository(const Ok(ReportOutcome.rechazadoProtegido));
    final container = _container(lists, reports);
    addTearDown(container.dispose);

    final notifier =
        container.read(detailActionControllerProvider(_sender).notifier);
    await notifier.reportAndBlock(ThreatCategory.callcenter);

    final state = container.read(detailActionControllerProvider(_sender));
    expect(state.phase, DetailActionPhase.success);
    expect(state.outcome, ReportOutcome.rechazadoProtegido);
    expect(lists.store[_sender], ListKind.negra);
  });
}
