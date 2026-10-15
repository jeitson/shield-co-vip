import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/app.dart';
import 'package:shield_app/core/config/app_config.dart';
import 'package:shield_app/core/config/config_providers.dart';
import 'package:shield_app/features/auth/data/datasources/auth_session_store.dart';
import 'package:shield_app/features/auth/data/dtos/auth_session_dto.dart';
import 'package:shield_app/features/auth/presentation/auth_providers.dart';

/// Store de sesión en memoria para pruebas (evita el platform channel de
/// `flutter_secure_storage`). Sin sesión persistida.
class _EmptySessionStore implements AuthSessionStore {
  @override
  Future<AuthSessionDto?> read() async => null;

  @override
  Future<void> write(AuthSessionDto session) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  testWidgets('la app arranca y, sin sesión, muestra la pantalla de acceso', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.dev()),
          authSessionStoreProvider.overrideWithValue(_EmptySessionStore()),
        ],
        child: const ShieldApp(),
      ),
    );

    // La restauración de sesión resuelve a "sin sesión"; el guard sale del
    // splash hacia login (DN-02). Se usa pump con duración fija porque el
    // spinner del splash mantiene una animación continua (pumpAndSettle no
    // converge).
    await tester.pump(); // splash
    await tester.pump(const Duration(milliseconds: 100)); // resuelve guard
    await tester.pump(const Duration(milliseconds: 100)); // navega a login

    // Botón primario de la pantalla de acceso (DN-02, sin modo invitado).
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
