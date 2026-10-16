import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Tarjeta de **priming**: explica por qué se necesita el rol de filtrado de
/// llamadas **antes** de lanzar el diálogo del SO (`04-app-flutter` §04.5) y
/// comunica con transparencia que la protección de llamadas está inactiva
/// (degradación honesta, §00.6). No finge proteger.
class PermissionPriming extends StatelessWidget {
  const PermissionPriming({required this.onEnable, super.key});

  final Future<void> Function() onEnable;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.phone_disabled_outlined,
            color: AppColors.warning,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protección de llamadas inactiva',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Para bloquear llamadas peligrosas necesitamos el rol de '
                  'filtrado de llamadas de Android. Sin él, no interceptamos '
                  'llamadas.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: onEnable,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: AppColors.bgRoot,
                  ),
                  child: const Text('Activar filtrado de llamadas'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
