import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Nota de privacidad del detalle (RN-DETAIL-02): el reporte es 100% anónimo.
class PrivacyFooter extends StatelessWidget {
  const PrivacyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppRadii.cardLarge),
        border: Border.all(color: AppColors.borderSubtle.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surface3,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.4),
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.verified_user_outlined,
              size: 18,
              color: AppColors.accentCyan,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu privacidad está protegida',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Al reportar un número, tus contactos, mensajes e información '
                  'personal nunca se comparten. Tu reporte es 100% anónimo.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
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
