import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/presentation/event_time_format.dart';
import 'package:shield_app/features/events/presentation/widgets/quarantine_sandbox.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';

/// Tarjeta de un evento interceptado (CallsScreen.tsx · timeline item).
///
/// La clasificación (badges CONFIABLE/BLOQUEADO y estado de los botones) se
/// observa de `membershipProvider` por `sender`, de modo que clasificar refleja
/// el cambio en todos los eventos del mismo número (R7.5). La severidad se
/// comunica con color **y** texto redundante (`ThreatLevel.label`), nunca solo
/// por color (R11.3, WCAG).
class EventCard extends ConsumerWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onDetails,
    required this.onExportSic,
  });

  final InterceptedEvent event;
  final VoidCallback onDetails;
  final VoidCallback onExportSic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final level = event.level;
    final accent = level.color;
    final membership = ref.watch(membershipProvider(event.sender)).valueOrNull;
    final isTrusted = membership == ListKind.confianza;
    final isBlacklisted = membership == ListKind.negra;

    return Material(
      color: AppColors.surface1,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Stack(
        children: [
          // Glow lateral de severidad.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                boxShadow: [
                  BoxShadow(color: accent.withValues(alpha: 0.6), blurRadius: 8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md + AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, textTheme, accent, isTrusted, isBlacklisted),
                const SizedBox(height: AppSpacing.sm),
                _diagnosisBanner(textTheme, accent),
                if (event.hasQuarantine) ...[
                  const SizedBox(height: AppSpacing.sm),
                  QuarantineSandbox(content: event.quarantinedContent!),
                ],
                const SizedBox(height: AppSpacing.md),
                _actions(context, ref, textTheme, isTrusted, isBlacklisted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(
    BuildContext context,
    TextTheme textTheme,
    Color accent,
    bool isTrusted,
    bool isBlacklisted,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconBox(accent),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    event.sender,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _badge(event.level.label, accent),
                  if (isTrusted) _badge('CONFIABLE', AppColors.success),
                  if (isBlacklisted) _badge('BLOQUEADO', AppColors.danger),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    formatEventTime(event.timestamp),
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Text(
                    '  •  ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  Flexible(
                    child: Text(
                      event.reputationTag,
                      style: textTheme.labelSmall?.copyWith(color: accent),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Ver detalles',
          onPressed: onDetails,
          icon: const Icon(Icons.more_vert, size: 18),
          color: AppColors.textSecondary,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
      ],
    );
  }

  Widget _iconBox(Color accent) {
    final icon = switch (event.type) {
      ContactChannel.sms => Icons.sms_failed_outlined,
      ContactChannel.call => switch (event.level) {
        ThreatLevel.alto => Icons.phone_disabled_outlined,
        ThreatLevel.medio => Icons.smart_toy_outlined,
        ThreatLevel.bajo => Icons.nightlight_outlined,
      },
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, size: 20, color: accent),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _diagnosisBanner(TextTheme textTheme, Color accent) {
    final icon = switch (event.level) {
      ThreatLevel.alto => Icons.warning_amber_outlined,
      ThreatLevel.medio => Icons.headset_off_outlined,
      ThreatLevel.bajo => Icons.policy_outlined,
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.surface2.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '${event.threatTitle}: ',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: event.diagnosis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(
    BuildContext context,
    WidgetRef ref,
    TextTheme textTheme,
    bool isTrusted,
    bool isBlacklisted,
  ) {
    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.surface4, width: 0.5),
        ),
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _ActionButton(
            icon: Icons.block,
            label: isBlacklisted ? 'En Lista Negra' : 'Lista Negra',
            color: AppColors.danger,
            filled: isBlacklisted,
            onTap: () => _classify(
              context,
              ref,
              target: isBlacklisted ? null : ListKind.negra,
              toastOn: '${event.sender} agregado a lista negra',
              toastOff: '${event.sender} removido de lista negra',
              wasActive: isBlacklisted,
            ),
          ),
          _ActionButton(
            icon: Icons.verified_user_outlined,
            label: isTrusted ? 'Confiable' : 'De confianza',
            color: AppColors.success,
            filled: isTrusted,
            onTap: () => _classify(
              context,
              ref,
              target: isTrusted ? null : ListKind.confianza,
              toastOn: '${event.sender} añadido a confianza',
              toastOff: '${event.sender} marcado como no confiable',
              wasActive: isTrusted,
            ),
          ),
          if (event.isSicEligible)
            _ActionButton(
              icon: Icons.download,
              label: 'Exportar SIC',
              color: AppColors.success,
              filled: false,
              onTap: onExportSic,
            ),
        ],
      ),
    );
  }

  Future<void> _classify(
    BuildContext context,
    WidgetRef ref, {
    required ListKind? target,
    required String toastOn,
    required String toastOff,
    required bool wasActive,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(classifyNumberProvider)
        .call(event.sender, target, origin: ListOrigin.evento);

    final message = result.fold(
      (_) => wasActive ? toastOff : toastOn,
      (failure) => failure.message,
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2500), // RN-CALLS-06
        ),
      );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.bgRoot : color;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: filled ? color : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.chip),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.chip),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15, color: fg),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
