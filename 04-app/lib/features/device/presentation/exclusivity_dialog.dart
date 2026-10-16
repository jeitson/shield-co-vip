import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';

/// Diálogo de **exclusividad por número** (DA-03 / RN-DEV-02): el número ya está
/// protegido en otro dispositivo. Advierte que continuar revocará aquel, que
/// quedará desprotegido. Devuelve `true` si el usuario confirma.
Future<bool> showExclusivityDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface1,
      icon: const Icon(Icons.devices_other, color: AppColors.warning),
      title: const Text('Número protegido en otro dispositivo'),
      content: const Text(
        'Este número ya está protegido en otro dispositivo. Si continúas aquí, '
        'aquel quedará desprotegido (la protección es exclusiva por número). '
        '¿Deseas tomar la protección en este dispositivo?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Proteger aquí'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
