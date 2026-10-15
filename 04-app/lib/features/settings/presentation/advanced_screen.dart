import 'package:flutter/material.dart';
import 'package:shield_app/core/widgets/placeholder_screen.dart';

/// Ajustes avanzados (05-listas-y-configuracion). Listas blanca/negra locales,
/// configuración del escudo y telemetría opt-in. Lógica pendiente.
class AdvancedScreen extends StatelessWidget {
  const AdvancedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Avanzados',
      icon: Icons.tune_outlined,
      description: 'Listas locales, configuración y telemetría.',
    );
  }
}
