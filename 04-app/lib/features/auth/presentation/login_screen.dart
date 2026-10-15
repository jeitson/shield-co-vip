import 'package:flutter/material.dart';
import 'package:shield_app/core/widgets/placeholder_screen.dart';

/// Pantalla de acceso (01-autenticacion). Punto de entrada con guard de auth
/// (DN-02): sin modo invitado. Lógica de negocio pendiente.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso')),
      body: const PlaceholderScreen(
        title: 'Iniciar sesión',
        icon: Icons.lock_outline,
        description: 'Autenticación por email (MVP). OTP de celular en fase futura.',
      ),
    );
  }
}
