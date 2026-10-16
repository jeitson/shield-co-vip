import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shield_app/features/events/presentation/intercepted_events_bridge.dart';

/// Shell principal con barra de navegación inferior (08-navegacion-y-shell).
///
/// Envuelve las ramas con estado del `StatefulShellRoute` para preservar el
/// estado de cada pestaña (shield / calls / report / advanced) al cambiar.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Drena la cola de interceptaciones producidas por el nativo (llamadas/SMS
    // bloqueados) y las persiste en el historial. Vivo mientras el shell lo
    // esté (tras login); re-drena al volver a primer plano.
    ref.watch(interceptedEventsDrainerProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Escudo',
          ),
          NavigationDestination(
            icon: Icon(Icons.call_outlined),
            selectedIcon: Icon(Icons.call),
            label: 'Registro',
          ),
          NavigationDestination(
            icon: Icon(Icons.gavel_outlined),
            selectedIcon: Icon(Icons.gavel),
            label: 'Denuncia',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Avanzados',
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    // initialLocation=true vuelve a la raíz de la rama si ya se está en ella.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
