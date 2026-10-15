import 'package:flutter/material.dart';
import 'package:shield_app/core/widgets/placeholder_screen.dart';

/// Pantalla de registro (01-autenticacion). Lógica de negocio pendiente.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: const PlaceholderScreen(
        title: 'Crear cuenta',
        icon: Icons.person_add_alt_1_outlined,
      ),
    );
  }
}
