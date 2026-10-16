import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';

/// Pestañas de vector Llamada/SMS del detalle (R1.4). La pestaña inicial la fija
/// la pantalla según el `type` del evento.
class VectorTabs extends StatelessWidget {
  const VectorTabs({
    super.key,
    required this.active,
    required this.onChanged,
    this.hasSms = true,
  });

  final ContactChannel active;
  final ValueChanged<ContactChannel> onChanged;

  /// Si el evento no es SMS, la pestaña SMS queda deshabilitada visualmente.
  final bool hasSms;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.bgRoot,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.borderSubtle.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tab(
              context,
              label: 'Llamada',
              icon: Icons.call_missed,
              selected: active == ContactChannel.call,
              onTap: () => onChanged(ContactChannel.call),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _tab(
              context,
              label: 'SMS',
              icon: Icons.sms_outlined,
              selected: active == ContactChannel.sms,
              onTap: hasSms ? () => onChanged(ContactChannel.sms) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final enabled = onTap != null;
    final fg = selected
        ? AppColors.accentCyan
        : (enabled ? AppColors.textSecondary : AppColors.textMuted);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? AppColors.surface3 : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(
                      color: fg,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
