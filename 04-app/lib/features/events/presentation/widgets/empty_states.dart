import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Panel de estado vacío/carga/error reutilizable del timeline (R6).
class EventsStatePanel extends StatelessWidget {
  const EventsStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  /// Vacío inicial de bienvenida (EST-CALLS-03): sin ningún evento.
  const EventsStatePanel.welcome({super.key})
    : icon = Icons.verified_user_outlined,
      title = 'Tu terminal está protegida',
      message =
          'Cuando el escudo neutralice una llamada o SMS, aparecerá aquí. '
          'Aún no hay eventos registrados.',
      onRetry = null;

  /// Vacío por filtro (EST-CALLS-02): hay eventos pero el criterio no coincide.
  const EventsStatePanel.noResults({super.key})
    : icon = Icons.search_off_outlined,
      title = 'No hay eventos con este criterio',
      message = 'Ajusta la búsqueda o los filtros para ver más resultados.',
      onRetry = null;

  /// Error de carga (EST-CALLS-05): permite reintentar.
  const EventsStatePanel.error({super.key, required VoidCallback retry})
    : icon = Icons.error_outline,
      title = 'No se pudo cargar el registro',
      message = 'Ocurrió un problema al leer el historial local.',
      onRetry = retry;

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton simple mientras se cargan los eventos (EST-CALLS-04).
class EventsLoadingSkeleton extends StatelessWidget {
  const EventsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          height: 96,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface1.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.15),
            ),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}
