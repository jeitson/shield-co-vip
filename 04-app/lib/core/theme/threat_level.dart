import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';

/// Nivel de amenaza con su color asociado.
///
/// Centraliza el trío de severidad recurrente (`06-design-system.md` §6.2):
/// ALTO → rojo, MEDIO → ámbar, BAJO → verde. Evita repetir el ternario de
/// color por toda la UI.
///
/// Accesibilidad: la severidad NO debe comunicarse solo por color. Usar
/// siempre [label] (texto redundante) y/o un icono/forma junto al color para
/// cumplir con daltonismo y WCAG (ver advertencia en §6.2).
enum ThreatLevel {
  alto,
  medio,
  bajo;

  /// Color principal del nivel (texto/icono/borde).
  Color get color => switch (this) {
        ThreatLevel.alto => AppColors.danger,
        ThreatLevel.medio => AppColors.warning,
        ThreatLevel.bajo => AppColors.success,
      };

  /// Etiqueta textual redundante para accesibilidad.
  String get label => switch (this) {
        ThreatLevel.alto => 'ALTO',
        ThreatLevel.medio => 'MEDIO',
        ThreatLevel.bajo => 'BAJO',
      };
}
