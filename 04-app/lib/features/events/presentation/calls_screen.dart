import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shield_app/core/router/app_routes.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/presentation/controllers/events_filter_controller.dart';
import 'package:shield_app/features/events/presentation/events_providers.dart';
import 'package:shield_app/features/events/presentation/state/events_view_state.dart';
import 'package:shield_app/features/events/presentation/widgets/empty_states.dart';
import 'package:shield_app/features/events/presentation/widgets/event_card.dart';
import 'package:shield_app/features/events/presentation/widgets/filter_chips.dart';
import 'package:shield_app/features/events/presentation/widgets/telemetry_tiles.dart';

/// PANT-CALLS · Registro de eventos interceptados (03-registro-eventos).
///
/// Timeline filtrable y buscable de llamadas/SMS neutralizados, con telemetría
/// real, acciones de clasificación (confianza/negra con exclusividad RN-05) y
/// navegación al detalle. Fiel a `CallsScreen.tsx`; solo tokens de `core/theme`.
class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({super.key});

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Carga la siguiente página al acercarse al final del scroll (R12).
  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      final paged = ref.read(pagedVisibleEventsProvider);
      if (paged.hasMore) {
        ref.read(visiblePageSizeProvider.notifier).loadMore();
      }
    }
  }

  void _onExportSic(InterceptedEvent event) {
    // Enganche del flujo de evidencia SIC (spec 06-canales-denuncia). Aquí solo
    // el punto de entrada; el flujo real se implementa en esa spec.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Exportación SIC disponible próximamente'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openDetail(InterceptedEvent event) {
    context.goNamed(
      AppRoutes.eventDetailName,
      pathParameters: {'id': event.id},
    );
  }

  Widget _loadMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: TextButton.icon(
        onPressed: () =>
            ref.read(visiblePageSizeProvider.notifier).loadMore(),
        icon: const Icon(Icons.expand_more, size: 18),
        label: const Text('Ver más'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: SafeArea(
        child: ListView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            const TelemetryTiles(),
            const SizedBox(height: AppSpacing.lg),
            _searchField(),
            const SizedBox(height: AppSpacing.lg),
            const FilterChips(),
            const SizedBox(height: AppSpacing.lg),
            _listHeader(context),
            const SizedBox(height: AppSpacing.md),
            _body(eventsAsync),
            const SizedBox(height: AppSpacing.lg),
            _privacyBanner(context),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchCtrl,
      onChanged: (value) {
        ref.read(eventsFilterControllerProvider.notifier).setQuery(value);
        setState(() {}); // refresca el icono-afijo (filtro ↔ limpiar)
      },
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar número, entidad o fragmento…',
        fillColor: AppColors.bgRoot,
        prefixIcon: const Icon(Icons.search, size: 18),
        suffixIcon: _searchCtrl.text.isEmpty
            ? const Icon(Icons.filter_list, size: 18)
            : IconButton(
                tooltip: 'Limpiar',
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  _searchCtrl.clear();
                  ref
                      .read(eventsFilterControllerProvider.notifier)
                      .setQuery('');
                  setState(() {});
                },
              ),
      ),
    );
  }

  Widget _listHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              const Icon(
                Icons.history_toggle_off,
                size: 16,
                color: AppColors.accentCyan,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Flexible(
                child: Text(
                  'Registro Criptográfico',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                'MOTOR LOCAL v4.1',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _body(AsyncValue<List<InterceptedEvent>> eventsAsync) {
    return eventsAsync.when(
      loading: () => const EventsLoadingSkeleton(),
      error: (_, _) => EventsStatePanel.error(
        retry: () => ref.invalidate(eventsStreamProvider),
      ),
      data: (_) {
        final paged = ref.watch(pagedVisibleEventsProvider);
        return switch (paged.emptyReason) {
          EmptyReason.initial => const EventsStatePanel.welcome(),
          EmptyReason.filtered => const EventsStatePanel.noResults(),
          EmptyReason.none => Column(
            children: [
              for (final e in paged.events) ...[
                EventCard(
                  event: e,
                  onDetails: () => _openDetail(e),
                  onExportSic: () => _onExportSic(e),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (paged.hasMore) _loadMoreButton(),
            ],
          ),
        };
      },
    );
  }

  Widget _privacyBanner(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: AppColors.bgRoot,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.successStrong.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified,
              size: 18,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aislamiento Criptográfico Local',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ningún registro ni número telefónico sale de tu dispositivo. '
                  'Todo el filtrado corre en hardware aislado.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
