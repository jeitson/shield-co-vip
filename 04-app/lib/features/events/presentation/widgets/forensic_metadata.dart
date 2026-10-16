import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/presentation/event_time_format.dart';

/// Metadatos forenses del evento (R1.3): fecha/hora, ubicación reportada, tipo
/// de actividad, categoría, reputación y diagnóstico.
class ForensicMetadata extends StatelessWidget {
  const ForensicMetadata({super.key, required this.event});

  final InterceptedEvent event;

  @override
  Widget build(BuildContext context) {
    final rows = <({IconData icon, String label, String value})>[
      (
        icon: Icons.schedule,
        label: 'Fecha y hora',
        value: formatEventTime(event.timestamp),
      ),
      (
        icon: Icons.place_outlined,
        label: 'Ubicación reportada',
        value: event.details?.ubicacion ?? 'No disponible',
      ),
      (
        icon: Icons.report_gmailerrorred_outlined,
        label: 'Tipo de actividad',
        value: event.threatTitle,
      ),
      (
        icon: Icons.category_outlined,
        label: 'Categoría',
        value: event.category.label,
      ),
      (
        icon: Icons.fingerprint,
        label: 'Reputación',
        value: event.reputationTag,
      ),
      (
        icon: Icons.policy_outlined,
        label: 'Diagnóstico',
        value: event.diagnosis,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppRadii.cardLarge),
        border: Border.all(color: AppColors.borderSubtle.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _row(context, rows[i]),
          ],
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    ({IconData icon, String label, String value}) data,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(data.icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.label.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.value,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
