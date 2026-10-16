import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Botón primario de autenticación con color **pintado explícitamente**.
///
/// No usa `FilledButton`/`ElevatedButton` a propósito: en algunos dispositivos
/// (p. ej. Material You de Motorola) el `ColorScheme` dinámico del sistema
/// filtraba un fondo magenta pese a fijar el tema. Aquí el color del fondo y del
/// texto son constantes del design system, imposibles de sobreescribir por el SO.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String label;

  /// `null` deshabilita el botón.
  final VoidCallback? onPressed;

  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool loading;

  /// Overrides opcionales de color (p. ej. estado "hecho" en verde).
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    final bg = enabled
        ? (backgroundColor ?? AppColors.accentCyan)
        : AppColors.surface3;
    final fg = enabled
        ? (foregroundColor ?? AppColors.accentCyanInk)
        : AppColors.textMuted;

    final textStyle = Theme.of(context).textTheme.titleMedium
        ?.copyWith(color: fg, fontWeight: FontWeight.bold);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadii.card),
          splashColor: AppColors.accentCyanInk.withValues(alpha: 0.12),
          highlightColor: AppColors.accentCyanInk.withValues(alpha: 0.06),
          child: Container(
            width: double.infinity,
            height: 52,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ] else if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: 20, color: fg),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!loading && trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(trailingIcon, size: 20, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
