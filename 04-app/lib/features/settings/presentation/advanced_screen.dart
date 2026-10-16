import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shield_app/core/config/config_providers.dart';
import 'package:shield_app/core/router/app_routes.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/auth/presentation/auth_providers.dart';
import 'package:shield_app/features/events/presentation/dev_event_seeder.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';
import 'package:shield_app/features/settings/presentation/widgets/law2300_hours_card.dart';

/// Ajustes avanzados (05-listas-y-configuracion). Menú de secciones: acceso a la
/// **gestión de listas** (pantalla propia con back), el **horario legal Ley
/// 2300** en acordeón (solo lectura), acceso al **Simulador** y **cierre de
/// sesión** (DN-02).
///
/// Las listas (confianza/negra) viven en su propia pantalla (`ListsScreen`) por
/// la cantidad de interacción que manejan; aquí solo se muestra el acceso con el
/// conteo. El "Modo Marco Móvil" del prototipo no se incluye (chrome, no producto).
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

  Future<void> _seedDevEvents(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final n = await ref.read(devEventSeederProvider)();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Se sembraron $n eventos de prueba en el registro'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).valueOrNull;
    final textTheme = Theme.of(context).textTheme;
    final isDev = ref.watch(appConfigProvider).enableLogging;
    final confianza = ref.watch(confianzaNumbersProvider).valueOrNull;
    final negra = ref.watch(negraNumbersProvider).valueOrNull;
    final listsSubtitle = (confianza == null || negra == null)
        ? 'Números de confianza y bloqueados'
        : '${confianza.length} en confianza · ${negra.length} bloqueados';

    return Scaffold(
      appBar: AppBar(title: const Text('Avanzados')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // --- Protección (accesos a listas, horario y simulador) ---
          Text(
            'PROTECCIÓN',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _Card(
            child: Column(
              children: [
                // Listas → pantalla propia con back.
                ListTile(
                  leading: const Icon(
                    Icons.playlist_add_check,
                    color: AppColors.accentCyan,
                  ),
                  title: Text('Listas locales', style: textTheme.bodyLarge),
                  subtitle: Text(listsSubtitle, style: textTheme.bodySmall),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textMuted,
                  ),
                  onTap: () => context.pushNamed(AppRoutes.listsName),
                ),
                const Divider(height: 1, color: AppColors.surface4),
                // Horario legal Ley 2300 → acordeón (solo lectura).
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    leading: const Icon(
                      Icons.schedule,
                      color: AppColors.accentMint,
                    ),
                    title: Text(
                      'Horario legal (Ley 2300)',
                      style: textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      'Franja permitida de contacto comercial',
                      style: textTheme.bodySmall,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    children: const [Law2300HoursCard(embedded: true)],
                  ),
                ),
                const Divider(height: 1, color: AppColors.surface4),
                // Simulador → pantalla propia (ya existía).
                ListTile(
                  leading: const Icon(
                    Icons.play_circle_outline,
                    color: AppColors.accentCyan,
                  ),
                  title: Text('Abrir Simulador', style: textTheme.bodyLarge),
                  subtitle: Text(
                    'Prueba el motor con números de ejemplo',
                    style: textTheme.bodySmall,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textMuted,
                  ),
                  onTap: () => context.pushNamed(AppRoutes.simulatorName),
                ),
              ],
            ),
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
          _Card(
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
                  leading: const Icon(Icons.logout, color: AppColors.danger),
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

          // --- Herramientas de desarrollo (solo flavor dev) ---
          if (isDev) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'DESARROLLO',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _Card(
              child: ListTile(
                leading: const Icon(
                  Icons.science_outlined,
                  color: AppColors.accentCyan,
                ),
                title: Text('Sembrar eventos de prueba', style: textTheme.bodyLarge),
                subtitle: Text(
                  'Inserta 3 interceptaciones de ejemplo en el registro '
                  '(validación en dispositivo).',
                  style: textTheme.bodySmall,
                ),
                onTap: () => _seedDevEvents(context, ref),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tarjeta contenedora estándar de Avanzados (superficie + borde sutil).
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.3),
        ),
      ),
      child: child,
    );
  }
}

