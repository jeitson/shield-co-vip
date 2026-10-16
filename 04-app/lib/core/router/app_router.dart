import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shield_app/core/router/app_routes.dart';
import 'package:shield_app/features/auth/presentation/auth_providers.dart';
import 'package:shield_app/features/auth/presentation/login_screen.dart';
import 'package:shield_app/features/auth/presentation/register_screen.dart';
import 'package:shield_app/features/auth/presentation/splash_screen.dart';
import 'package:shield_app/features/events/presentation/calls_screen.dart';
import 'package:shield_app/features/events/presentation/record_detail_screen.dart';
import 'package:shield_app/features/reports/presentation/report_channels_screen.dart';
import 'package:shield_app/features/settings/presentation/advanced_screen.dart';
import 'package:shield_app/features/settings/presentation/lists_screen.dart';
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
    // Arranque en el splash mientras se restaura la sesión (R3.3). El guard
    // redirige a login (DN-02) o al escudo según el estado resuelto.
    initialLocation: AppRoutes.splashPath,
    debugLogDiagnostics: true,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final status = ref.read(authStatusProvider);
      final location = state.matchedLocation;
      final onSplash = location == AppRoutes.splashPath;
      final loggingIn =
          location == AppRoutes.loginPath || location == AppRoutes.registerPath;

      // Mientras no se resuelva el estado inicial, mantener el splash.
      if (status == AuthStatus.unknown) {
        return onSplash ? null : AppRoutes.splashPath;
      }

      final authenticated = status == AuthStatus.authenticated;

      // Ya resuelto: salir del splash hacia el destino correcto.
      if (onSplash) {
        return authenticated ? AppRoutes.shieldPath : AppRoutes.loginPath;
      }

      // Sin sesión y fuera de las pantallas de auth → a login.
      if (!authenticated && !loggingIn) return AppRoutes.loginPath;

      // Con sesión en una pantalla de auth → al escudo.
      if (authenticated && loggingIn) return AppRoutes.shieldPath;

      return null;
    },
    routes: [
      // --- Arranque ---
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),

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
      GoRoute(
        path: AppRoutes.listsPath,
        name: AppRoutes.listsName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ListsScreen(),
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
