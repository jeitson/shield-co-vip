import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/auth/presentation/auth_providers.dart';

/// Ajustes avanzados (05-listas-y-configuracion). Listas blanca/negra locales,
/// configuración del escudo y telemetría opt-in — pendientes de su propio flujo.
///
/// Por ahora expone el **cierre de sesión** (requisito de DN-02: debe existir
/// logout), útil además para validar el flujo de auth en pruebas.
class AdvancedScreen extends ConsumerWidget {
  const AdvancedScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: const Text('Cerrar sesión'),
        content: const Text(
          'Se cerrará la sesión en este dispositivo y volverás a la pantalla '
          'de acceso. Tus datos locales no se eliminan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // El guard del router detecta la ausencia de sesión y redirige a login.
      await ref.read(sessionProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).valueOrNull;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Avanzados')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Secciones futuras (05-listas-y-configuracion).
          _SectionHint(
            icon: Icons.tune_outlined,
            text: 'Listas locales, configuración del escudo y telemetría '
                'llegarán en su propio flujo.',
          ),
          const SizedBox(height: AppSpacing.xl),

          // --- Cuenta ---
          Text(
            'CUENTA',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                if (session != null)
                  ListTile(
                    leading: const Icon(
                      Icons.account_circle_outlined,
                      color: AppColors.accentMint,
                    ),
                    title: Text(
                      session.user.nombreCompleto.trim().isEmpty
                          ? session.user.correo
                          : session.user.nombreCompleto,
                      style: textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      session.user.correo,
                      style: textTheme.bodySmall,
                    ),
                  ),
                if (session != null)
                  const Divider(height: 1, color: AppColors.surface4),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: AppColors.danger,
                  ),
                  title: Text(
                    'Cerrar sesión',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                  onTap: () => _confirmLogout(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Nota discreta para las secciones aún no construidas.
class _SectionHint extends StatelessWidget {
  const _SectionHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
