import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Sandbox del payload del SMS en el detalle forense (PANT-DETAIL, R2).
///
/// Renderiza el texto como `SelectableText` con el **enlace resaltado** en un
/// `TextSpan` plano: los enlaces **NO son navegables** (R2.2, RN-DETAIL-06) —
/// no se usa ningún autolink. Acompaña una alerta de "enlace peligroso" (R2.3).
class SmsPayloadSandbox extends StatelessWidget {
  const SmsPayloadSandbox({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final spans = _highlightLink(
      content,
      base: textTheme.bodyMedium?.copyWith(
        color: AppColors.textPrimary.withValues(alpha: 0.95),
      ),
      link: textTheme.bodyMedium?.copyWith(
        color: AppColors.danger,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.danger,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgRoot,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: AppColors.borderSubtle.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sms_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Mensaje de texto sospechoso',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              _dangerBadge(textTheme),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Texto plano seleccionable, con el enlace resaltado pero NO navegable.
          SelectableText.rich(
            TextSpan(children: spans),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          _linkAlert(textTheme),
        ],
      ),
    );
  }

  Widget _dangerBadge(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.dangerStrong.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Peligroso',
        style: textTheme.labelSmall?.copyWith(
          color: AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _linkAlert(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.dangerStrong.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.link_off, size: 16, color: AppColors.danger),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Enlace peligroso. Intenta suplantar a una empresa conocida para '
              'robar tus datos. No lo abras: aquí está neutralizado y no es '
              'navegable.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Parte el texto para resaltar el primer enlace `http…` sin hacerlo clicable.
  static List<TextSpan> _highlightLink(
    String text, {
    TextStyle? base,
    TextStyle? link,
  }) {
    final match = RegExp(r'https?:\/\/\S+').firstMatch(text);
    if (match == null) {
      return [TextSpan(text: text, style: base)];
    }
    return [
      if (match.start > 0)
        TextSpan(text: text.substring(0, match.start), style: base),
      TextSpan(text: text.substring(match.start, match.end), style: link),
      if (match.end < text.length)
        TextSpan(text: text.substring(match.end), style: base),
    ];
  }
}
