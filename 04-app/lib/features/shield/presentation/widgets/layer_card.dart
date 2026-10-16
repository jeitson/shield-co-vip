import 'package:flutter/material.dart';
import 'package:shield_app/core/db/daos/shield_config_dao.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Severidad de la advertencia por capa (RN-SHIELD-02).
enum LayerSeverity { alta, media }

/// Metadatos visuales y textos de una capa (del documento de negocio
/// `02-escudo-dashboard`). Mantiene la UI libre de literales dispersos.
class LayerSpec {
  const LayerSpec({
    required this.layer,
    required this.icon,
    required this.title,
    required this.badge,
    required this.description,
    required this.severity,
    required this.warningTitle,
    required this.warningBody,
  });

  final ShieldLayer layer;
  final IconData icon;
  final String title;
  final String badge;
  final String description;
  final LayerSeverity severity;
  final String warningTitle;
  final String warningBody;

  static const extorsion = LayerSpec(
    layer: ShieldLayer.extorsion,
    icon: Icons.gavel,
    title: 'Llamadas extorsivas',
    badge: 'Crítico',
    description:
        'Bloqueo automático de números carcelarios y redes criminales.',
    severity: LayerSeverity.alta,
    warningTitle: 'Advertencia de riesgo alto',
    warningBody:
        'Al desactivar, quedarás expuesto a llamadas procedentes de cárceles, '
        'números reportados por extorsión y fraudes telefónicos.',
  );

  static const callcenter = LayerSpec(
    layer: ShieldLayer.callcenter,
    icon: Icons.ring_volume,
    title: 'Call center molestos',
    badge: 'Spam',
    description:
        'Filtro de discadores robóticos y rastreadores de disponibilidad.',
    severity: LayerSeverity.media,
    warningTitle: 'Advertencia de exposición',
    warningBody:
        'Al desactivar, entrarán llamadas automatizadas spam y "llamadas '
        'fantasma" que cuelgan para validar si tu línea está activa.',
  );

  static const ley = LayerSpec(
    layer: ShieldLayer.ley,
    icon: Icons.policy,
    title: 'Ley dejen de fregar',
    badge: 'Legal',
    description: 'Cumplimiento estricto de horarios y canales comerciales no autorizados.',
    severity: LayerSeverity.media,
    warningTitle: 'Invasión horaria habilitada',
    warningBody:
        'Al desactivar, bancos y entidades comerciales podrán llamarte en '
        'horarios no hábiles, fines de semana o fuera de lo legal.',
  );

  static const all = [extorsion, callcenter, ley];
}

/// Tarjeta-módulo de una capa con switch táctil y panel de advertencia cuando se
/// desactiva (ShieldScreen.tsx · Protection Modules).
class LayerCard extends StatelessWidget {
  const LayerCard({
    required this.spec,
    required this.enabled,
    required this.onToggle,
    super.key,
  });

  final LayerSpec spec;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Color del borde cuando está desactivada: según severidad.
    final warnColor = spec.severity == LayerSeverity.alta
        ? AppColors.danger
        : AppColors.warning;

    // `Material` propio: el `Switch` interno requiere un ancestro `Material`.
    // Darlo aquí hace que la tarjeta sea autónoma (no depende del Scaffold del
    // shell) y testeable de forma aislada.
    return Material(
      color: enabled ? AppColors.surface2 : AppColors.surface3,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: enabled
                ? AppColors.borderSubtle.withValues(alpha: 0.3)
                : warnColor.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface3,
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                    border: Border.all(
                      color: AppColors.borderSubtle.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(spec.icon, size: 22, color: AppColors.accentMint),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              spec.title,
                              style: textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _Badge(label: spec.badge),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(spec.description, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                // Switch accesible (objetivo táctil ≥ 48dp por defecto).
                Semantics(
                  label: 'Activar ${spec.title}',
                  toggled: enabled,
                  child: Switch(
                    value: enabled,
                    onChanged: onToggle,
                    activeThumbColor: AppColors.bgRoot,
                    activeTrackColor: AppColors.success,
                  ),
                ),
              ],
            ),
            // Panel de advertencia (solo si está desactivada).
            if (!enabled) ...[
              const SizedBox(height: AppSpacing.md),
              _WarningPanel(spec: spec, color: warnColor),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface4,
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WarningPanel extends StatelessWidget {
  const _WarningPanel({required this.spec, required this.color});
  final LayerSpec spec;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bg = spec.severity == LayerSeverity.alta
        ? AppColors.dangerStrong.withValues(alpha: 0.25)
        : color.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            spec.severity == LayerSeverity.alta
                ? Icons.warning_amber_rounded
                : Icons.report_problem_outlined,
            size: 18,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec.warningTitle.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(spec.warningBody, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
