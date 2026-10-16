import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/shield/domain/shield_status.dart';

/// Barra de estado "Filtro Zero-Knowledge" con el indicador de color y el
/// contador `N / 3 ACTIVOS` (ShieldScreen.tsx · Status Header Bar).
class StatusBar extends StatelessWidget {
  const StatusBar({required this.status, required this.activeCount, super.key});

  final ShieldStatus status;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = status.color;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                // Punto de estado con glow.
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color,
                        blurRadius: 10,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Flexible(
                  child: Text(
                    'FILTRO ZERO-KNOWLEDGE',
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Píldora N / 3 ACTIVOS.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface3,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(status.icon, size: 14, color: color),
                const SizedBox(width: AppSpacing.xs + 2),
                Text(
                  '$activeCount / 3 ACTIVOS',
                  style: textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
