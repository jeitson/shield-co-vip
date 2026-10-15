import 'package:flutter/material.dart';

/// Tokens de color de Cifrado Cero.
///
/// Extraídos literalmente del design system (`01-docs/06-design-system.md`).
/// Tema oscuro único; no existe tema claro. No usar colores hardcodeados en
/// la UI: siempre referenciar estos tokens o el `ColorScheme` del tema.
abstract final class AppColors {
  // --- Superficies / fondos ---
  /// Fondo app más oscuro, inputs.
  static const bgRoot = Color(0xFF0A0E15);

  /// Fondo del "dispositivo" / body.
  static const bgSurface = Color(0xFF0F131B);

  /// Tarjetas.
  static const surface1 = Color(0xFF181C23);

  /// Tarjetas elevadas / filas.
  static const surface2 = Color(0xFF1C2027);

  /// Chips, botones secundarios.
  static const surface3 = Color(0xFF262A32);

  /// Pistas de switch, divisores sólidos.
  static const surface4 = Color(0xFF31353D);

  /// Bordes (usar casi siempre con alpha /20–/40).
  static const borderSubtle = Color(0xFF3B494C);

  // --- Acento / marca ---
  /// Acción primaria, foco, enlaces, activo.
  static const accentCyan = Color(0xFF00E5FF);

  /// Hover de botón primario.
  static const accentCyanHover = Color(0xFF9CF0FF);

  /// Estado intermedio (loading).
  static const accentCyan2 = Color(0xFF00DAF3);

  /// Texto sobre fondo cyan.
  static const accentCyanInk = Color(0xFF00363D);

  /// Marca / avatar / texto suave de acento.
  static const accentMint = Color(0xFFC3F5FF);

  // --- Semánticos ---
  /// Protegido / confiable / activo (nivel BAJO).
  static const success = Color(0xFF7DFFA2);
  static const successStrong = Color(0xFF05E777);
  static const successInk = Color(0xFF003918);

  /// Protección parcial / nivel MEDIO. Token único (unifica amber-400/#f59e0b,
  /// inconsistencia detectada en 06-design-system §6.9).
  static const warning = Color(0xFFF59E0B);

  /// Riesgo / nivel ALTO (texto e iconos).
  static const danger = Color(0xFFFFB4AB);

  /// Fondo rojo profundo (lista negra, GAULA).
  static const dangerStrong = Color(0xFF93000A);
  static const danger700 = Color(0xFFBA1A1A);
  static const danger600 = Color(0xFFDC2626);

  // --- Texto ---
  /// Texto principal.
  static const textPrimary = Color(0xFFDFE2ED);

  /// Texto secundario / descripciones.
  static const textSecondary = Color(0xFFBAC9CC);

  /// Texto terciario / placeholders / labels.
  static const textMuted = Color(0xFF849396);
}
