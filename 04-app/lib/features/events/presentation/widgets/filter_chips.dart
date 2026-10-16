import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/events/domain/entities/event_filter.dart';
import 'package:shield_app/features/events/presentation/controllers/events_filter_controller.dart';
import 'package:shield_app/features/events/presentation/events_providers.dart';

/// Fila de chips de filtro (CallsScreen.tsx · Filtros Rápidos). Un chip activo a
/// la vez: "Todos (N)", Llamadas, SMS | Alto, Medio, Bajo (RF-CALLS-03).
class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(totalEventsCountProvider);
    final filter = ref.watch(eventsFilterControllerProvider).filter;
    final ctrl = ref.read(eventsFilterControllerProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'Todos ($total)',
            selected: filter.isAll,
            selectedBg: AppColors.accentCyan,
            selectedFg: AppColors.accentCyanInk,
            onTap: ctrl.clearFilter,
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          _Chip(
            label: 'Llamadas',
            icon: Icons.call,
            selected: filter.type == EventTypeFilter.call,
            selectedBg: AppColors.accentCyan,
            selectedFg: AppColors.accentCyanInk,
            onTap: () => ctrl.setTypeChip(EventTypeFilter.call),
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          _Chip(
            label: 'SMS',
            icon: Icons.sms,
            selected: filter.type == EventTypeFilter.sms,
            selectedBg: AppColors.accentCyan,
            selectedFg: AppColors.accentCyanInk,
            onTap: () => ctrl.setTypeChip(EventTypeFilter.sms),
          ),
          _divider(),
          _Chip(
            label: 'Alto',
            dotColor: AppColors.danger,
            selected: filter.level == EventLevelFilter.alto,
            selectedBg: AppColors.dangerStrong,
            selectedFg: Colors.white,
            onTap: () => ctrl.setLevelChip(EventLevelFilter.alto),
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          _Chip(
            label: 'Medio',
            dotColor: AppColors.warning,
            selected: filter.level == EventLevelFilter.medio,
            selectedBg: AppColors.warning,
            selectedFg: AppColors.bgSurface,
            onTap: () => ctrl.setLevelChip(EventLevelFilter.medio),
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          _Chip(
            label: 'Bajo',
            dotColor: AppColors.success,
            selected: filter.level == EventLevelFilter.bajo,
            selectedBg: AppColors.success,
            selectedFg: AppColors.successInk,
            onTap: () => ctrl.setLevelChip(EventLevelFilter.bajo),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 16,
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    color: AppColors.surface4,
  );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.selectedBg,
    required this.selectedFg,
    required this.onTap,
    this.icon,
    this.dotColor,
  });

  final String label;
  final bool selected;
  final Color selectedBg;
  final Color selectedFg;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fg = selected ? selectedFg : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? selectedBg : AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dotColor != null) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: selected ? selectedFg : dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                  ],
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: fg),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    label.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: fg,
                      letterSpacing: 0.8,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
