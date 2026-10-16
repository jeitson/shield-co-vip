import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';

/// Estado agregado del escudo derivado del número de capas activas (RN-03).
///
/// Es la fuente de verdad del color/estado en toda la app (barra de estado,
/// hero, header). Lógica pura: `statusFromActiveCount`.
enum ShieldStatus {
  total,
  parcial,
  riesgo;

  /// Deriva el estado del número de capas activas (0–3), según RN-03.
  static ShieldStatus fromActiveCount(int active) => switch (active) {
    3 => ShieldStatus.total,
    >= 1 => ShieldStatus.parcial,
    _ => ShieldStatus.riesgo,
  };

  /// Color semántico (tokens de `core/theme`; nada hardcodeado).
  Color get color => switch (this) {
    ShieldStatus.total => AppColors.success,
    ShieldStatus.parcial => AppColors.warning,
    ShieldStatus.riesgo => AppColors.danger,
  };

  /// Icono de la píldora de estado (lock/shield/warning).
  IconData get icon => switch (this) {
    ShieldStatus.total => Icons.lock,
    ShieldStatus.parcial => Icons.shield,
    ShieldStatus.riesgo => Icons.warning_amber_rounded,
  };

  /// Título corto (RN-03 / ShieldScreen.tsx).
  String get title => switch (this) {
    ShieldStatus.total => 'Protección Total Activa',
    ShieldStatus.parcial => 'Protección Parcial',
    ShieldStatus.riesgo => 'Protección Desactivada - En Riesgo',
  };

  /// Descripción de apoyo bajo el escudo del hero.
  String get description => switch (this) {
    ShieldStatus.total =>
      'Tu línea se encuentra blindada contra fraudes, acoso y violaciones a la '
          'privacidad horaria.',
    ShieldStatus.parcial =>
      'Has desactivado capas clave de defensa. Tu terminal tiene brechas '
          'operativas abiertas.',
    ShieldStatus.riesgo =>
      'Atención: tu línea telefónica está totalmente indefensa ante estafas y '
          'tráfico no deseado.',
  };

  /// `true` para total/parcial (escudo con check); `false` para riesgo (alerta).
  bool get isProtected => this != ShieldStatus.riesgo;
}
