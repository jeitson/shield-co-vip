import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shield_app/core/router/app_routes.dart';
import 'package:shield_app/features/auth/presentation/auth_providers.dart';
import 'package:shield_app/features/auth/presentation/login_screen.dart';
import 'package:shield_app/features/auth/presentation/register_screen.dart';
import 'package:shield_app/features/events/presentation/calls_screen.dart';
import 'package:shield_app/features/events/presentation/record_detail_screen.dart';
import 'package:shield_app/features/reports/presentation/report_channels_screen.dart';
import 'package:shield_app/features/settings/presentation/advanced_screen.dart';
import 'package:shield_app/features/shield/presentation/shield_screen.dart';
import 'package:shield_app/features/simulator/presentation/simulator_screen.dart';
import 'package:shield_app/shell/app_shell.dart';

/// Keys de navegadores: raíz (auth + detalle) y shell (ramas con bottom nav).
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Provee el [GoRouter] de la app, reconstruyendo su redirección cuando cambia
/// el estado de autenticación.
///
/// Corrige los gaps del prototipo (`03-mapa-navegacion.md`): pila real con
/// back nativo, deep links y guard de auth (DN-02, sin modo invitado).
final appRouterProvider = Provider<GoRouter>((ref) {
  // Escucha de auth para refrescar las redirecciones del router.
  final authListenable = ValueNotifier<AuthStatus>(
    ref.read(authStatusProvider),
  );
  ref.listen<AuthStatus>(authStatusProvider, (_, next) {
    authListenable.value = next;
  });
  ref.onDispose(authListenable.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.shieldPath,
    debugLogDiagnostics: true,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final status = ref.read(authStatusProvider);
      final loggingIn = state.matchedLocation == AppRoutes.loginPath ||
          state.matchedLocation == AppRoutes.registerPath;

      // Mientras no se resuelva el estado inicial, no redirigir.
      if (status == AuthStatus.unknown) return null;

      final authenticated = status == AuthStatus.authenticated;

      // Sin sesión y fuera de las pantallas de auth → a login.
      if (!authenticated && !loggingIn) return AppRoutes.loginPath;

      // Con sesión en una pantalla de auth → al escudo.
      if (authenticated && loggingIn) return AppRoutes.shieldPath;

      return null;
    },
    routes: [
      // --- Auth (sin bottom nav) ---
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),

      // --- Detalle y modales (sobre la raíz, con back nativo) ---
      GoRoute(
        path: AppRoutes.eventDetailPath,
        name: AppRoutes.eventDetailName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => RecordDetailScreen(
          eventId: state.pathParameters['id'] ?? 'desconocido',
        ),
      ),
      GoRoute(
        path: AppRoutes.simulatorPath,
        name: AppRoutes.simulatorName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SimulatorScreen(),
      ),

      // --- Shell con bottom nav (ramas con estado preservado) ---
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.shieldPath,
                name: AppRoutes.shieldName,
                builder: (context, state) => const ShieldScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.callsPath,
                name: AppRoutes.callsName,
                builder: (context, state) => const CallsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reportPath,
                name: AppRoutes.reportName,
                builder: (context, state) => const ReportChannelsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.advancedPath,
                name: AppRoutes.advancedName,
                builder: (context, state) => const AdvancedScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
