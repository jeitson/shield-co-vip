import 'package:flutter/material.dart';
import 'package:shield_app/core/widgets/placeholder_screen.dart';

/// Simulador en vivo (07-simulador). Demostración del motor de precedencia.
/// Lógica pendiente.
class SimulatorScreen extends StatelessWidget {
  const SimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador')),
      body: const PlaceholderScreen(
        title: 'Simulador',
        icon: Icons.play_circle_outline,
        description: 'Prueba el motor de bloqueo con casos simulados.',
      ),
    );
  }
}
