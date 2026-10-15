import 'package:flutter/material.dart';
import 'package:shield_app/core/widgets/placeholder_screen.dart';

/// Escudo / Dashboard (02-escudo-dashboard). Estado agregado de protección
/// (RN-03). Lógica de negocio pendiente.
class ShieldScreen extends StatelessWidget {
  const ShieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Escudo',
      icon: Icons.shield_outlined,
      description: 'Estado de protección y capas (llamadas / SMS).',
    );
  }
}
