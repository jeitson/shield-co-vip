import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';

/// Categorías reportables del catálogo RN-07 (subconjunto curado para el reporte
/// comunitario; excluye "Comercial sin riesgo", que no es un reporte de abuso).
const List<ThreatCategory> kReportableCategories = [
  ThreatCategory.extorsion,
  ThreatCategory.phishing,
  ThreatCategory.callcenter,
  ThreatCategory.llamadaFantasma,
  ThreatCategory.ley2300,
];

/// Selector de categoría del problema (R3): chips sobre `ThreatCategory`, un
/// chip activo a la vez. La pantalla preselecciona la categoría del evento.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ThreatCategory? selected;
  final ValueChanged<ThreatCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿QUÉ TIPO DE PROBLEMA FUE?',
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            // Dos columnas de chips (como el prototipo), con ancho acotado para
            // que las etiquetas largas no desborden (se recortan con ellipsis).
            final chipWidth =
                (constraints.maxWidth - AppSpacing.sm) / 2;
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final cat in kReportableCategories)
                  SizedBox(
                    width: chipWidth,
                    child: _chip(context, cat, cat == selected),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, ThreatCategory cat, bool isSelected) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: isSelected,
      label: cat.label,
      child: Material(
        color: isSelected ? AppColors.surface2 : AppColors.bgRoot,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        child: InkWell(
          onTap: () => onSelected(cat),
          borderRadius: BorderRadius.circular(AppRadii.chip),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.chip),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentCyan.withValues(alpha: 0.5)
                    : AppColors.borderSubtle.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _iconFor(cat),
                  size: 16,
                  color: isSelected ? AppColors.accentCyan : AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    cat.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppColors.accentCyan
                          : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(ThreatCategory cat) => switch (cat) {
        ThreatCategory.extorsion => Icons.gavel,
        ThreatCategory.phishing => Icons.link_off,
        ThreatCategory.callcenter => Icons.support_agent,
        ThreatCategory.llamadaFantasma => Icons.phone_paused,
        ThreatCategory.ley2300 => Icons.schedule,
        ThreatCategory.comercial => Icons.storefront,
      };
}
