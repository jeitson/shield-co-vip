import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/core/theme/app_theme.dart';
import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/presentation/events_providers.dart';
import 'package:shield_app/features/events/presentation/record_detail_screen.dart';
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
  @override
  Future<Result<ReportOutcome>> report(CommunityReport report) async {
    calls++;
    return const Ok(ReportOutcome.pendiente);
  }

  @override
  Future<Result<bool>> wasReportedByMe(String numero) async => const Ok(false);
}

InterceptedEvent _event({
  ContactChannel type = ContactChannel.sms,
  String? quarantined =
      'Verifica tu envío en https://envio-track.secure-link.co/alert',
}) =>
    InterceptedEvent(
      id: 'e1',
      sender: '+573184928810',
      type: type,
      level: ThreatLevel.alto,
      timestamp: DateTime(2026, 1, 1, 15, 42),
      threatTitle: 'Posible estafa por mensaje',
      category: ThreatCategory.phishing,
      reputationTag: 'VoIP no registrado',
      diagnosis: 'Enlace de suplantación',
      quarantinedContent: quarantined,
    );

Future<void> _pump(
  WidgetTester tester, {
  required AsyncValue<InterceptedEvent?> event,
  _FakeLists? lists,
  _FakeReports? reports,
}) async {
  tester.view.physicalSize = const Size(1200, 5200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        eventByIdProvider.overrideWith((ref, id) async {
          return event.when(
            data: (e) => e,
            loading: () => Future<InterceptedEvent?>.delayed(
                const Duration(seconds: 1), () => null),
            error: (e, _) => throw e,
          );
        }),
        listsRepositoryProvider.overrideWith((ref) async => lists ?? _FakeLists()),
        reportsRepositoryProvider
            .overrideWithValue(reports ?? _FakeReports()),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const RecordDetailScreen(eventId: 'e1'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _unmount(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox.shrink());

Finder _scrollable() => find.byType(Scrollable).first;

void main() {
  testWidgets('muestra número y sandbox del SMS no navegable', (tester) async {
    await _pump(tester, event: AsyncData(_event()));

    expect(find.text('+573184928810'), findsOneWidget);
    expect(find.text('Mensaje de texto sospechoso'), findsOneWidget);
    // No hay ningún GestureDetector/InkWell envolviendo el enlace: el sandbox
    // usa SelectableText.rich plano (enlace no navegable, R2.2).
    expect(find.byType(SelectableText), findsWidgets);
    await _unmount(tester);
  });

  testWidgets('evento tipo llamada no muestra el sandbox', (tester) async {
    await _pump(
      tester,
      event: AsyncData(_event(type: ContactChannel.call, quarantined: null)),
    );
    expect(find.text('Mensaje de texto sospechoso'), findsNothing);
    await _unmount(tester);
  });

  testWidgets('"Bloquear solo para mí" bloquea y muestra confirmación', (
    tester,
  ) async {
    final lists = _FakeLists();
    await _pump(tester, event: AsyncData(_event()), lists: lists);

    final localBtn = find.text('Bloquear solo para mí');
    await tester.scrollUntilVisible(localBtn, 300, scrollable: _scrollable());
    await tester.tap(localBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(lists.store['+573184928810'], ListKind.negra);
    expect(find.text('Número silenciado localmente'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('"Reportar y bloquear" bloquea y reporta', (tester) async {
    final lists = _FakeLists();
    final reports = _FakeReports();
    await _pump(
      tester,
      event: AsyncData(_event()),
      lists: lists,
      reports: reports,
    );

    final dualBtn = find.text('Reportar y bloquear');
    await tester.scrollUntilVisible(dualBtn, 300, scrollable: _scrollable());
    await tester.tap(dualBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(lists.store['+573184928810'], ListKind.negra);
    expect(reports.calls, 1);
    expect(find.text('¡Bloqueado y Sincronizado!'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('id sin evento → "Evento no disponible"', (tester) async {
    await _pump(tester, event: const AsyncData<InterceptedEvent?>(null));
    expect(find.text('Evento no disponible'), findsOneWidget);
    await _unmount(tester);
  });
}
