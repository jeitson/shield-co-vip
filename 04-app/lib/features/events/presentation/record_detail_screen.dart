import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/events/presentation/event_time_format.dart';
import 'package:shield_app/features/events/presentation/events_providers.dart';

/// Detalle de evento (04-detalle-evento). Recibe el `id` por ruta y carga el
/// evento desde el repositorio (R10: deep-link-capable, no depende de pasar el
/// objeto en memoria).
///
/// El análisis forense completo + reportar/bloquear es la spec `04`; aquí se
/// entrega el **enganche de datos** y el estado "evento no disponible"
/// (RF-DETAIL-11) para que la navegación desde el registro no quede rota.
class RecordDetailScreen extends ConsumerWidget {
  const RecordDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      backgroundColor: AppColors.bgSurface,
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _unavailable(context),
        data: (event) {
          if (event == null) return _unavailable(context);
          // Vista mínima de datos (la ficha forense completa es la spec 04).
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                event.sender,
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${event.level.label} • ${formatEventTime(event.timestamp)}',
                style: textTheme.labelMedium?.copyWith(
                  color: event.level.color,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _row('Amenaza', event.threatTitle, textTheme),
              _row('Categoría', event.category.label, textTheme),
              _row('Reputación', event.reputationTag, textTheme),
              _row('Diagnóstico', event.diagnosis, textTheme),
              if (event.hasQuarantine)
                _row('Contenido', event.quarantinedContent!, textTheme),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _unavailable(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_outlined,
              size: 40,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Evento no disponible',
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'El evento que intentas abrir ya no existe o no está disponible.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
