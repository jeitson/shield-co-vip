import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Muestra el contenido de un SMS en cuarentena dentro de un "sandbox" seguro
/// (CallsScreen.tsx · Quarantined content). El texto se renderiza como texto
/// plano seleccionable: **los enlaces no son navegables** (R8.2, RN-CALLS-04),
/// por eso NO se usa ningún widget de autolink.
class QuarantineSandbox extends StatelessWidget {
  const QuarantineSandbox({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgRoot,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Contenido neutralizado:',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 12,
                    color: AppColors.accentCyan2,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Sandbox seguro',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.accentCyan2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Texto plano seleccionable: enlaces NO clicables (privacidad, R8.2).
          SelectableText(
            '"$content"',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
