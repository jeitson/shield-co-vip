import 'package:flutter/material.dart';
import 'package:shield_app/core/legal/ley2300_hours.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Tarjeta **de solo lectura** con la franja horaria legal de la Ley 2300
/// (RN-08, spec 05 R11). Las franjas son normativas y fijas (DN-05): no se
/// editan ni hay switches aquí. La capa `ley` se activa/desactiva desde el
/// Dashboard; la evaluación en tiempo de contacto la hace el motor (spec 08).
class Law2300HoursCard extends StatelessWidget {
  const Law2300HoursCard({this.embedded = false, super.key});

  /// Cuando se muestra dentro de otro contenedor (p. ej. un acordeón), omite su
  /// propia superficie/borde y padding para no anidar tarjetas.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!embedded) ...[
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 18,
                color: AppColors.accentMint,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Horario legal de contacto comercial',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Text(
          'Franja en la que la ley permite llamadas comerciales y de cobranza. '
          'Es normativa (Ley 2300 de 2023) y no se puede editar.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),

        ..._rows(context),
      ],
    );

    if (embedded) return content;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: content,
    );
  }

  List<Widget> _rows(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return [
          // Franjas con horario.
          for (final w in Ley2300Hours.windows)
            _HoursRow(label: w.label, value: w.rangeText),
          // Día de bloqueo total.
          _HoursRow(
            label: Ley2300Hours.blocked24hLabel,
            value: Ley2300Hours.blocked24hText,
            danger: true,
          ),

          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'El bloqueo funciona sin conexión; los festivos colombianos se '
                  'calculan en el dispositivo.',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
    ];
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow({
    required this.label,
    required this.value,
    this.danger = false,
  });

  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: danger ? AppColors.danger : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
