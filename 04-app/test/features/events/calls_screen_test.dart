import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shield_app/core/theme/app_theme.dart';
import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/presentation/calls_screen.dart';
import 'package:shield_app/features/events/presentation/events_providers.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';

InterceptedEvent _event({
  required String id,
  String sender = '+573001234567',
  ContactChannel type = ContactChannel.call,
  ThreatLevel level = ThreatLevel.alto,
  ThreatCategory category = ThreatCategory.extorsion,
  String threatTitle = 'Extorsión Carcelaria',
  String reputationTag = 'VoIP no registrado',
  String diagnosis = 'Patrón de amenaza',
  String? quarantined,
}) => InterceptedEvent(
  id: id,
  sender: sender,
  type: type,
  level: level,
  timestamp: DateTime(2026, 1, 1, 12),
  threatTitle: threatTitle,
  category: category,
  reputationTag: reputationTag,
  diagnosis: diagnosis,
  quarantinedContent: quarantined,
);

Future<GoRouter> _pump(
  WidgetTester tester,
  List<InterceptedEvent> events, {
  ListKind? membership,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const CallsScreen()),
      GoRoute(
        path: '/calls/:id',
        name: 'event-detail',
        builder: (_, state) =>
            Scaffold(body: Text('DETALLE ${state.pathParameters['id']}')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        eventsStreamProvider.overrideWith((ref) => Stream.value(events)),
        membershipProvider.overrideWith((ref, numero) => Stream.value(membership)),
      ],
      child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return router;
}

Future<void> _unmount(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox.shrink());

void main() {
  testWidgets('vacío inicial de bienvenida cuando no hay eventos', (
    tester,
  ) async {
    await _pump(tester, []);
    expect(find.text('Tu terminal está protegida'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('lista eventos y muestra el badge de nivel (texto redundante)', (
    tester,
  ) async {
    await _pump(tester, [_event(id: 'a')]);
    expect(find.text('+573001234567'), findsOneWidget);
    // Severidad comunicada por texto (R11.3): el nivel 'ALTO' aparece como badge
    // en la tarjeta además del chip de filtro → al menos una ocurrencia.
    expect(find.text('ALTO'), findsWidgets);
    expect(find.text('Extorsión Carcelaria: '), findsNothing); // va en RichText
    await _unmount(tester);
  });

  testWidgets('búsqueda sin coincidencias → vacío por filtro', (tester) async {
    await _pump(tester, [_event(id: 'a', threatTitle: 'Extorsión')]);

    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.pump();

    expect(find.text('No hay eventos con este criterio'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('chip SMS filtra solo SMS (combinable)', (tester) async {
    await _pump(tester, [
      _event(id: 'call', sender: '+573000000001', type: ContactChannel.call),
      _event(id: 'sms', sender: '+573000000002', type: ContactChannel.sms),
    ]);

    await tester.tap(find.text('SMS'));
    await tester.pump();

    expect(find.text('+573000000002'), findsOneWidget);
    expect(find.text('+573000000001'), findsNothing);
    await _unmount(tester);
  });

  testWidgets('Exportar SIC visible solo en categoría Ley 2300', (tester) async {
    await _pump(tester, [
      _event(id: 'ley', category: ThreatCategory.ley2300, level: ThreatLevel.bajo),
    ]);
    expect(find.text('Exportar SIC'), findsOneWidget);
    await _unmount(tester);

    await _pump(tester, [_event(id: 'ext', category: ThreatCategory.extorsion)]);
    expect(find.text('Exportar SIC'), findsNothing);
    await _unmount(tester);
  });

  testWidgets('sandbox de cuarentena solo en SMS con contenido', (tester) async {
    await _pump(tester, [
      _event(id: 'sms', type: ContactChannel.sms, quarantined: 'Clic aqui http://x'),
    ]);
    expect(find.textContaining('Contenido neutralizado'), findsOneWidget);
    await _unmount(tester);

    await _pump(tester, [_event(id: 'call', type: ContactChannel.call)]);
    expect(find.textContaining('Contenido neutralizado'), findsNothing);
    await _unmount(tester);
  });

  testWidgets('badge CONFIABLE aparece según la membresía', (tester) async {
    await _pump(tester, [_event(id: 'a')], membership: ListKind.confianza);
    expect(find.text('CONFIABLE'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('tocar "Ver detalles" navega al detalle con el id', (
    tester,
  ) async {
    await _pump(tester, [_event(id: 'evt-77')]);

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();

    expect(find.text('DETALLE evt-77'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('paginación: solo se renderiza la primera página (R12)', (
    tester,
  ) async {
    // 60 eventos > 50 (página): el evento #55 no debe existir aún en el árbol,
    // porque la ventana inicial recorta a los primeros 50 (y el ListView no
    // construye lo que está fuera de la ventana de datos).
    final events = List.generate(
      60,
      (i) => _event(
        id: 'e$i',
        sender: '+573000${i.toString().padLeft(6, '0')}',
      ),
    );
    await _pump(tester, events);

    // El primero sí está; uno más allá de la página no está materializado.
    expect(find.text('+573000000000'), findsOneWidget);
    expect(find.text('+573000000055'), findsNothing);
    await _unmount(tester);
  });
}
