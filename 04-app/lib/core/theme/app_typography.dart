import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';

/// Familias tipográficas del design system (`06-design-system.md` §6.3).
///
/// Deben empaquetarse como assets locales para operar offline (§6.8), no vía
/// CDN. Mientras no se agreguen los binarios de las fuentes al `pubspec.yaml`,
/// estas familias caen al tipo de letra del sistema (Flutter usa el fallback
/// cuando la familia no está declarada). Al añadir los assets, declararlos en
/// `pubspec.yaml` con estos mismos nombres de familia.
abstract final class AppFontFamily {
  /// Títulos, valores de métrica, botones.
  static const headline = 'SpaceGrotesk';

  /// Texto corrido, descripciones.
  static const body = 'HankenGrotesk';

  /// Números, labels en mayúsculas, datos técnicos, badges.
  static const mono = 'JetBrainsMono';
}

/// Construye el [TextTheme] oscuro de la app combinando las tres familias.
///
/// La escala se basa en los tamaños observados en el prototipo (§6.3): 9–38px.
abstract final class AppTypography {
  static TextTheme buildTextTheme() {
    const primary = AppColors.textPrimary;
    const secondary = AppColors.textSecondary;

    return const TextTheme(
      // Display / títulos grandes → Space Grotesk.
      displayLarge: TextStyle(
        fontFamily: AppFontFamily.headline,
        fontSize: 38,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppFontFamily.headline,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontFamily: AppFontFamily.headline,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFontFamily.headline,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      // Cuerpo → Hanken Grotesk.
      bodyLarge: TextStyle(
        fontFamily: AppFontFamily.body,
        fontSize: 15,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFontFamily.body,
        fontSize: 13,
        color: secondary,
      ),
      bodySmall: TextStyle(
        fontFamily: AppFontFamily.body,
        fontSize: 11,
        color: secondary,
      ),
      // Labels / datos técnicos → JetBrains Mono (mayúsculas, tracking).
      labelLarge: TextStyle(
        fontFamily: AppFontFamily.mono,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontFamily: AppFontFamily.mono,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontFamily: AppFontFamily.mono,
        fontSize: 10,
        letterSpacing: 0.5,
        color: AppColors.textMuted,
      ),
    );
  }
}
