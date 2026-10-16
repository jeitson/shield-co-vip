import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/presentation/widgets/vector_tabs.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';

/// Tarjeta de inspección del número (R1.2): número seleccionable, badge de
/// nivel de peligro (color + etiqueta textual, R13.3), badge de clasificación
/// actual y pestañas de vector.
class InspectionCard extends ConsumerWidget {
  const InspectionCard({
    super.key,
    required this.event,
    required this.activeVector,
    required this.onVectorChanged,
  });

  final InterceptedEvent event;
  final ContactChannel activeVector;
  final ValueChanged<ContactChannel> onVectorChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final membership = ref.watch(membershipProvider(event.sender)).valueOrNull;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppRadii.cardLarge),
        border: Border.all(color: AppColors.borderSubtle.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Número desconocido',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          event.type == ContactChannel.sms
                              ? Icons.sms_outlined
                              : Icons.call,
                          size: 20,
                          color: AppColors.accentMint,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: SelectableText(
                            event.sender,
                            style: textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _dangerBadge(textTheme),
            ],
          ),
          if (membership != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _membershipBadge(textTheme, membership),
          ],
          const SizedBox(height: AppSpacing.md),
          VectorTabs(
            active: activeVector,
            onChanged: onVectorChanged,
            hasSms: event.type == ContactChannel.sms,
          ),
        ],
      ),
    );
  }

  Widget _dangerBadge(TextTheme textTheme) {
    final level = event.level;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: level.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 12, color: level.color),
          const SizedBox(width: AppSpacing.xs),
          // Texto redundante al color (accesibilidad, R13.3).
          Text(
            'Peligro ${level.label}',
            style: textTheme.labelSmall?.copyWith(
              color: level.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _membershipBadge(TextTheme textTheme, ListKind kind) {
    final isBlocked = kind == ListKind.negra;
    final color = isBlocked ? AppColors.danger : AppColors.success;
    return Row(
      children: [
        Icon(
          isBlocked ? Icons.block : Icons.verified_outlined,
          size: 14,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          isBlocked ? 'Bloqueado' : 'De confianza',
          style: textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
