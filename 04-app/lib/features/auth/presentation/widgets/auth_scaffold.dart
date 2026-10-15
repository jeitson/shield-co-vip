import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Layout común de las pantallas de autenticación.
///
/// Reproduce el "enclave" del prototipo: fondo oscuro con un glow cyan sutil y
/// un scrim en gradiente (design system §6.1, móvil-first ≤ 420). Centra el
/// contenido, permite scroll y respeta el teclado. No se porta el chrome del
/// emulador (`04-app-flutter` §04.9).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: Stack(
        children: [
          // Glow ambiental cyan en la parte superior.
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentCyan.withValues(alpha: 0.12),
                      AppColors.bgSurface.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Scrim en gradiente para asentar el contenido.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xD90F131B), // bgSurface @ ~85%
                  AppColors.bgSurface,
                ],
              ),
            ),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
