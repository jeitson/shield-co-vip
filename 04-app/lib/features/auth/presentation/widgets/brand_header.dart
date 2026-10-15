import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Encabezado de marca de las pantallas de auth: icono en contenedor
/// redondeado + título + subtítulo (prototipo Login/Register).
class BrandHeader extends StatelessWidget {
  const BrandHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface2.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppRadii.cardLarge),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(icon, color: AppColors.accentCyan, size: 30),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
