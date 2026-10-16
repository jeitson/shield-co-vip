import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/events/presentation/event_time_format.dart';
import 'package:shield_app/features/events/presentation/events_providers.dart';

/// Las 3 micro-tarjetas de telemetría (CallsScreen.tsx · Bento Micro-Cards),
/// calculadas de los eventos reales (R5). Reactivas vía `telemetryProvider`.
class TelemetryTiles extends ConsumerWidget {
  const TelemetryTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(telemetryProvider);
    // Altura fija (sin IntrinsicHeight) para que `Flexible` en el header de cada
    // tile opere con ancho acotado y no bajo medición de ancho intrínseco.
    return SizedBox(
      height: 92,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Tile(
              label: 'HOY',
              value: '${t.today}',
              caption: 'Intercepciones',
              accent: AppColors.success,
              captionColor: AppColors.success,
              trailing: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _Tile(
              label: 'AHORRO',
              value: formatSecondsSaved(t.secondsSaved),
              caption: 'Tiempo salvado',
              accent: AppColors.accentMint,
              captionColor: AppColors.textSecondary,
              trailing: const Icon(
                Icons.timer_outlined,
                size: 14,
                color: AppColors.accentCyan,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _Tile(
              label: 'CRÍTICAS',
              value: '${t.critical}',
              caption: 'Riesgo Alto',
              accent: AppColors.danger,
              captionColor: AppColors.danger,
              trailing: const Icon(
                Icons.gpp_maybe_outlined,
                size: 14,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.value,
    required this.caption,
    required this.accent,
    required this.captionColor,
    required this.trailing,
  });

  final String label;
  final String value;
  final String caption;
  final Color accent;
  final Color captionColor;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: '$caption: $value',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: AppColors.borderSubtle.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                trailing,
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              caption,
              style: textTheme.labelSmall?.copyWith(color: captionColor),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
