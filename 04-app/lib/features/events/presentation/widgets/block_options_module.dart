import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/core/widgets/primary_button.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/presentation/controllers/detail_action_controller.dart';
import 'package:shield_app/features/events/presentation/state/detail_action_state.dart';
import 'package:shield_app/features/events/presentation/widgets/category_selector.dart';
import 'package:shield_app/features/reports/domain/entities/report_outcome.dart';

/// Módulo "Opciones de bloqueo" (R3–R9): explicación de las dos vías, selector
/// de categoría, nota opcional y los dos botones de acción con sus estados.
class BlockOptionsModule extends ConsumerStatefulWidget {
  const BlockOptionsModule({super.key, required this.event});

  final InterceptedEvent event;

  @override
  ConsumerState<BlockOptionsModule> createState() => _BlockOptionsModuleState();
}

class _BlockOptionsModuleState extends ConsumerState<BlockOptionsModule> {
  ThreatCategory? _category;
  final _noteController = TextEditingController();
  bool _categoryError = false;

  @override
  void initState() {
    super.initState();
    // Preselecciona la categoría del evento como sugerencia si es reportable
    // (RN-DETAIL-04: el usuario puede cambiarla, y debe confirmar para reportar).
    if (kReportableCategories.contains(widget.event.category)) {
      _category = widget.event.category;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String get _sender => widget.event.sender;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(detailActionControllerProvider(_sender));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(AppRadii.cardLarge),
        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(textTheme),
          const SizedBox(height: AppSpacing.lg),
          _explain(
            textTheme,
            icon: Icons.phone_disabled,
            title: '1. Bloquear en tu teléfono',
            body: 'No volverás a recibir llamadas ni mensajes de este número.',
            tint: AppColors.accentMint,
          ),
          const SizedBox(height: AppSpacing.sm),
          _explain(
            textTheme,
            icon: Icons.group_outlined,
            title: '2. Ayudar a proteger a otros',
            body: 'Reportamos el número a la comunidad, de forma anónima, para '
                'que también se bloquee y alerte a otros.',
            tint: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.lg),
          CategorySelector(
            selected: _category,
            onSelected: (c) => setState(() {
              _category = c;
              _categoryError = false;
            }),
          ),
          if (_categoryError) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Elige una categoría para reportar.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _noteField(textTheme),
          const SizedBox(height: AppSpacing.lg),
          _dualButton(state),
          const SizedBox(height: AppSpacing.sm),
          _localButton(textTheme, state),
          if (state.hasReportError) ...[
            const SizedBox(height: AppSpacing.md),
            _errorBanner(textTheme, state),
          ],
          if (state.isDualSuccess) ...[
            const SizedBox(height: AppSpacing.md),
            _outcomeBanner(textTheme, state),
          ],
        ],
      ),
    );
  }

  Widget _header(TextTheme textTheme) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.accentCyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadii.chip),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.shield_outlined,
              size: 18, color: AppColors.accentCyan),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Opciones de bloqueo',
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Elige cómo responder a este número',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _explain(
    TextTheme textTheme, {
    required IconData icon,
    required String title,
    required String body,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.borderSubtle.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tint),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
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

  Widget _noteField(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DETALLES ADICIONALES (OPCIONAL)',
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _noteController,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ej: Dicen ser de una empresa de envíos para pedir claves',
            hintStyle: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.bgRoot,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.card),
              borderSide: BorderSide(
                color: AppColors.borderSubtle.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.card),
              borderSide: const BorderSide(color: AppColors.accentCyan),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dualButton(DetailActionState state) {
    final label = switch (state.phase) {
      DetailActionPhase.generating when state.kind == DetailActionKind.dualReport =>
        'Generando Prueba ZK & Inmunizando…',
      DetailActionPhase.success when state.kind == DetailActionKind.dualReport =>
        '¡Bloqueado y Sincronizado!',
      _ => 'Reportar y bloquear',
    };
    final success = state.isDualSuccess;
    return PrimaryButton(
      label: label,
      loading: state.isGenerating,
      leadingIcon: success ? Icons.check_circle : Icons.shield,
      backgroundColor: success ? AppColors.successStrong : null,
      foregroundColor: success ? AppColors.successInk : null,
      onPressed: state.isGenerating ? null : _onReportAndBlock,
    );
  }

  Widget _localButton(TextTheme textTheme, DetailActionState state) {
    final done = state.localBlockDone;
    final busy = state.kind == DetailActionKind.localBlock &&
        state.phase == DetailActionPhase.generating;
    return Semantics(
      button: true,
      label: done ? 'Número silenciado localmente' : 'Bloquear solo para mí',
      child: Material(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: InkWell(
          onTap: (busy || done) ? null : _onBlockLocal,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  done ? Icons.check : Icons.person_off_outlined,
                  size: 18,
                  color: done ? AppColors.success : AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    done
                        ? 'Número silenciado localmente'
                        : 'Bloquear solo para mí',
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(
                      color: done ? AppColors.success : AppColors.textSecondary,
                      fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorBanner(TextTheme textTheme, DetailActionState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.dangerStrong.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              state.errorMessage ?? 'No se pudo enviar el reporte.',
              style: textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final category = _category;
              if (category == null) return;
              ref
                  .read(detailActionControllerProvider(_sender).notifier)
                  .retryReport(category);
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _outcomeBanner(TextTheme textTheme, DetailActionState state) {
    final outcome = state.outcome;
    final (icon, text, color) = switch (outcome) {
      ReportOutcome.yaReportado => (
          Icons.done_all,
          'Ya habías reportado este número. No se duplicó el reporte.',
          AppColors.success,
        ),
      ReportOutcome.rechazadoProtegido => (
          Icons.verified_user_outlined,
          'Número protegido: no entra a la lista comunitaria. Quedó bloqueado '
              'solo en tu teléfono.',
          AppColors.accentCyan,
        ),
      _ => (
          Icons.check_circle_outline,
          'Reporte enviado de forma anónima. Gracias por proteger a la comunidad.',
          AppColors.success,
        ),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _onReportAndBlock() {
    // RN-DETAIL-04: exige categoría consciente para reportar.
    final category = _category;
    if (category == null) {
      setState(() => _categoryError = true);
      return;
    }
    ref
        .read(detailActionControllerProvider(_sender).notifier)
        .reportAndBlock(category);
  }

  void _onBlockLocal() {
    ref.read(detailActionControllerProvider(_sender).notifier).blockLocal();
  }
}
