import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/platform/blocking_engine_android.dart';
import 'package:shield_app/core/theme/app_theme.dart';
import 'package:shield_app/features/auth/domain/entities/auth_session.dart';
import 'package:shield_app/features/auth/presentation/auth_providers.dart';
import 'package:shield_app/features/engine/presentation/engine_providers.dart';
import 'package:shield_app/features/shield/presentation/shield_providers.dart';
import 'package:shield_app/features/shield/presentation/shield_screen.dart';
import 'package:shield_app/features/sync/presentation/sync_providers.dart';

/// SessionNotifier de prueba: siempre "sin sesión", para que el registro de
/// dispositivo post-login del ShieldScreen haga early-return (celular vacío).
class _NullSessionNotifier extends SessionNotifier {
  @override
  AsyncValue<AuthSession?> build() => const AsyncData(null);
}

/// Fila de config de prueba (sin depender de drift en el widget test; la
/// persistencia real está cubierta por los tests de `core/db`).
ShieldConfigRow _row({
  bool extorsion = true,
  bool callcenter = true,
  bool ley = true,
}) => ShieldConfigRow(
  id: 1,
  extorsion: extorsion,
  callcenter: callcenter,
  ley: ley,
  updatedAt: DateTime(2026, 1, 1),
);

/// Monta el ShieldScreen con los providers de datos sustituidos por valores
/// controlados: aísla la pantalla de drift/plataforma/red y permite verificar el
/// comportamiento (CA-SHIELD-*). El motor es no-op → aparece el priming.
Future<void> _pumpShield(
  WidgetTester tester, {
  required Stream<ShieldConfigRow> configStream,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const ShieldScreen()),
      GoRoute(
        path: '/simulator',
        name: 'simulator',
        builder: (_, _) => const Scaffold(body: Text('SIMULADOR')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        shieldConfigProvider.overrideWith((ref) => configStream),
        blockingEngineProvider.overrideWithValue(const BlockingEngineNoop()),
        engineProjectionProvider.overrideWithValue(null),
        datasetCountProvider.overrideWith((ref) => Stream.value(300)),
        // Sin sesión → el registro de dispositivo post-login hace early-return,
        // aislando el test de la red/plataforma del subsistema devices.
        sessionProvider.overrideWith(() => _NullSessionNotifier()),
      ],
      child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

/// Desmonta el árbol para liberar los AnimationController del hero.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
}

void main() {
  testWidgets('arranca con 3/3 activos y protección total (CA-SHIELD-01)', (
    tester,
  ) async {
    await _pumpShield(tester, configStream: Stream.value(_row()));

    expect(find.text('3 / 3 ACTIVOS'), findsOneWidget);
    expect(find.text('Protección Total Activa'), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('con extorsión desactivada: estado parcial (CA-SHIELD-02)', (
    tester,
  ) async {
    await _pumpShield(
      tester,
      configStream: Stream.value(_row(extorsion: false)),
    );

    expect(find.text('2 / 3 ACTIVOS'), findsOneWidget);
    expect(find.text('Protección Parcial'), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('0 capas → estado de riesgo (CA-SHIELD-03)', (tester) async {
    await _pumpShield(
      tester,
      configStream: Stream.value(
        _row(extorsion: false, callcenter: false, ley: false),
      ),
    );

    expect(find.text('0 / 3 ACTIVOS'), findsOneWidget);
    expect(find.text('Protección Desactivada - En Riesgo'), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('muestra priming cuando falta el rol de call screening (§00.6)', (
    tester,
  ) async {
    await _pumpShield(tester, configStream: Stream.value(_row()));
    expect(find.text('Protección de llamadas inactiva'), findsOneWidget);

    await _unmount(tester);
  });
}
