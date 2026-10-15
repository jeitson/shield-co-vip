import 'package:flutter/material.dart';
import 'package:shield_app/core/widgets/placeholder_screen.dart';

/// Registro de eventos interceptados (03-registro-eventos). Lógica pendiente.
class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Registro',
      icon: Icons.call_outlined,
      description: 'Historial de llamadas y SMS interceptados.',
    );
  }
}
