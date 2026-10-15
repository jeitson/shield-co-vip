import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/app.dart';
import 'package:shield_app/core/config/app_config.dart';
import 'package:shield_app/core/config/config_providers.dart';

void main() {
  testWidgets('la app arranca y, sin sesión, muestra la pantalla de acceso',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.dev()),
        ],
        child: const ShieldApp(),
      ),
    );
    await tester.pumpAndSettle();

    // El guard de auth redirige a login (DN-02, sin modo invitado).
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
