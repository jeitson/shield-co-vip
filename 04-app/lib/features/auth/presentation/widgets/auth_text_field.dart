import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Campo de texto de las pantallas de auth con la estética del design system:
/// label mono en mayúsculas, icono-afijo, foco cyan y error inline accesible
/// (no comunicar estado solo por color, §6.9: hay texto de error explícito).
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.label,
    required this.icon,
    this.hint,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.errorText,
    this.suffix,
    this.enabled = true,
    this.autofillHints,
    super.key,
  });

  final String label;
  final IconData icon;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final Widget? suffix;
  final bool enabled;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          enabled: enabled,
          autofillHints: autofillHints,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
            suffixIcon: suffix,
            errorText: errorText,
            fillColor: AppColors.surface1.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
