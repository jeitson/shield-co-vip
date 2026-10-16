import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/core/theme/app_theme.dart';
import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/presentation/widgets/event_card.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/domain/repositories/lists_repository.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';
import 'package:shield_app/features/reports/domain/entities/community_report.dart';
import 'package:shield_app/features/reports/domain/entities/report_outcome.dart';
import 'package:shield_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:shield_app/features/reports/presentation/reports_providers.dart';

class _FakeLists implements ListsRepository {
  final Map<String, ListKind> store = {};
  @override
  Future<Result<void>> classify({
    required String numero,
    required ListKind? kind,
    ListOrigin origin = ListOrigin.evento,
  }) async {
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

class _FakeReports implements ReportsRepository {
  int calls = 0;
  CommunityReport? last;
  @override
  Future<Result<ReportOutcome>> report(CommunityReport report) async {
    calls++;
    last = report;
    return const Ok(ReportOutcome.pendiente);
  }

  @override
  Future<Result<bool>> wasReportedByMe(String numero) async => const Ok(false);
}

InterceptedEvent _event() => InterceptedEvent(
      id: 'e1',
      sender: '+573184928810',
      type: ContactChannel.call,
      level: ThreatLevel.alto,
      timestamp: DateTime(2026, 1, 1, 12),
      threatTitle: 'Extorsión',
      category: ThreatCategory.extorsion,
      reputationTag: 'VoIP',
      diagnosis: 'Patrón',
    );

void main() {
  testWidgets('la tarjeta muestra "Reportar y bloquear" (no "Lista Negra")',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final lists = _FakeLists();
    final reports = _FakeReports();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          listsRepositoryProvider.overrideWith((ref) async => lists),
          reportsRepositoryProvider.overrideWithValue(reports),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: EventCard(
              event: _event(),
              onDetails: () {},
              onExportSic: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Reportar y bloquear'), findsOneWidget);
    expect(find.text('Lista Negra'), findsNothing);

    await tester.tap(find.text('Reportar y bloquear'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Bloqueo local aplicado + reporte enviado con la categoría del evento.
    expect(lists.store['+573184928810'], ListKind.negra);
    expect(reports.calls, 1);
    expect(reports.last?.categoria, ThreatCategory.extorsion);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
