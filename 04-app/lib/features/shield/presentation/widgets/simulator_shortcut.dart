import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shield_app/core/router/app_routes.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Tarjeta de acceso rápido al Simulador (ShieldScreen.tsx · Simulator Shortcut).
/// El botón "Probar" navega al simulador (RF-SHIELD-08 / CA-SHIELD-08).
class SimulatorShortcut extends StatelessWidget {
  const SimulatorShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surface1, AppColors.surface2],
        ),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.chip),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              size: 18,
              color: AppColors.accentCyan,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Simulador de Tiempo Real', style: textTheme.titleMedium),
                Text(
                  'Prueba la experiencia de interceptación en pantalla bloqueada.',
                  style: textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () => context.pushNamed(AppRoutes.simulatorName),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentCyan,
              foregroundColor: AppColors.accentCyanInk,
            ),
            child: const Text('Probar'),
          ),
        ],
      ),
    );
  }
}
