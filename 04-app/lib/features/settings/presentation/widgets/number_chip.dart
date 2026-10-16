import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Chip de un número en una lista local, con acción de eliminar (spec 05, R6).
///
/// Estética del design system: superficie [AppColors.surface3] con un acento de
/// borde/ícono según la lista. El número se muestra en su forma canónica.
class NumberChip extends StatelessWidget {
  const NumberChip({
    required this.numero,
    required this.accentColor,
    required this.onDeleted,
    super.key,
  });

  /// Número canónico (E.164 o código corto).
  final String numero;

  /// Color de acento de la lista (cyan = confianza, danger = negra).
  final Color accentColor;

  /// Baja del número (clasificar con `kind == null`).
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface3,
      borderRadius: BorderRadius.circular(AppRadii.chip),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.xs,
          top: AppSpacing.xs,
          bottom: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              numero,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Semantics(
              button: true,
              label: 'Eliminar $numero de la lista',
              child: InkWell(
                onTap: onDeleted,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: accentColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
