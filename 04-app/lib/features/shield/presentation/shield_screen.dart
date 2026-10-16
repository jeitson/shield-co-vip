import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/db/daos/shield_config_dao.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/auth/presentation/auth_providers.dart';
import 'package:shield_app/features/device/presentation/device_providers.dart';
import 'package:shield_app/features/device/presentation/exclusivity_dialog.dart';
import 'package:shield_app/features/engine/presentation/engine_providers.dart';
import 'package:shield_app/features/shield/presentation/shield_providers.dart';
import 'package:shield_app/features/shield/presentation/widgets/layer_card.dart';
import 'package:shield_app/features/shield/presentation/widgets/metric_tiles.dart';
import 'package:shield_app/features/shield/presentation/widgets/permission_priming.dart';
import 'package:shield_app/features/shield/presentation/widgets/shield_hero.dart';
import 'package:shield_app/features/shield/presentation/widgets/simulator_shortcut.dart';
import 'package:shield_app/features/shield/presentation/widgets/status_bar.dart';

/// Escudo / Dashboard (`PANT-SHIELD`, 02-escudo-dashboard). Pantalla principal
/// tras login: estado agregado (RN-03), control de las 3 capas, contador de la
/// lista local, sincronización y acceso al simulador. Integra persistencia (A),
/// dataset/sync (B) y motor de bloqueo (C).
class ShieldScreen extends ConsumerStatefulWidget {
  const ShieldScreen({super.key});

  @override
  ConsumerState<ShieldScreen> createState() => _ShieldScreenState();
}

class _ShieldScreenState extends ConsumerState<ShieldScreen>
    with WidgetsBindingObserver {
  bool _deviceRegistered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Registro del dispositivo post-login (DA-02/03), una vez por montaje.
    WidgetsBinding.instance.addPostFrameCallback((_) => _registerDevice());
  }

  /// Registra este dispositivo con el número del perfil. Si el número ya está
  /// protegido en otro dispositivo, muestra el diálogo de exclusividad (DA-03).
  Future<void> _registerDevice() async {
    if (_deviceRegistered) return;
    _deviceRegistered = true;

    final session = ref.read(sessionProvider).valueOrNull;
    final celular = session?.user.celular ?? '';
    if (celular.isEmpty) return;

    final controller = ref.read(deviceSessionControllerProvider);

    try {
      // 1) Registrar/actualizar este dispositivo y resolver exclusividad. En el
      //    primer login el device no existe aún, así que SIEMPRE se registra
      //    primero (el refresh solo tiene sentido con un device ya registrado).
      final outcome = await controller.register(celular);
      if (!mounted) return;

      if (outcome == DeviceRegisterOutcome.requiereConfirmacion) {
        final confirmed = await showExclusivityDialog(context);
        if (confirmed) {
          await controller.confirmExclusivity(celular);
        }
      }

      // 2) Verificar revocación explícita (DA-04). Solo si el servidor confirma
      //    que el dispositivo fue revocado se borra el material y se cierra
      //    sesión. Un error transitorio NO saca al usuario del Escudo.
      final revoked = await controller.refreshAndWipeIfRevoked();
      if (revoked && mounted) {
        await ref.read(sessionProvider.notifier).logout();
      }
    } catch (_) {
      // El registro/refresh es best-effort: nunca debe impedir ver el Escudo.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Al reanudar, refrescar el estado de permisos (pudo cambiar en ajustes).
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(enginePermissionsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mantener viva la proyección del snapshot al motor: cada cambio de config o
    // dataset se refleja en el filtrado real (RF-SHIELD-04).
    ref.watch(engineProjectionProvider);

    final status = ref.watch(shieldStatusProvider);
    final activeCount = ref.watch(activeLayerCountProvider);
    final config = ref.watch(shieldConfigProvider);
    final permissions = ref.watch(enginePermissionsProvider).valueOrNull;
    final controller = ref.read(shieldControllerProvider);

    final topInset = MediaQuery.of(context).viewPadding.top;

    final enabled = <ShieldLayer, bool>{
      for (final l in ShieldLayer.values) l: _isEnabled(config.valueOrNull, l),
    };

    // `Material` propio (transparente): los controles interactivos del cuerpo
    // (`Switch`, `InkWell` de métricas y del acceso al simulador) requieren un
    // ancestro `Material`. Darlo aquí hace que la pantalla sea autónoma y no
    // dependa del `Scaffold` del shell, y evita anidar otro `Scaffold`.
    //
    // El contenido es un `ListView` desplazable. (Los hijos de un scrollable
    // reciben alto no acotado; por eso ningún hijo puede depender de un alto
    // infinito —ver `MetricTiles`, que acota su `Row` con `IntrinsicHeight`.)
    final needsCallScreening =
        permissions != null && !permissions.callScreeningGranted;

    return Material(
      type: MaterialType.transparency,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          topInset + AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Text('Escudo', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          StatusBar(status: status, activeCount: activeCount),
          const SizedBox(height: AppSpacing.lg),
          // Priming honesto (§00.6): si falta el rol de filtrado de llamadas, se
          // comunica que la protección de llamadas está inactiva.
          if (needsCallScreening) ...[
            PermissionPriming(onEnable: controller.requestCallScreening),
            const SizedBox(height: AppSpacing.lg),
          ],
          ShieldHero(status: status),
          const SizedBox(height: AppSpacing.lg),
          for (final spec in LayerSpec.all)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: LayerCard(
                spec: spec,
                enabled: enabled[spec.layer] ?? true,
                onToggle: (v) => controller.toggleLayer(spec.layer, v),
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          const MetricTiles(),
          const SizedBox(height: AppSpacing.lg),
          const SimulatorShortcut(),
        ],
      ),
    );
  }

  bool _isEnabled(ShieldConfigRow? row, ShieldLayer layer) {
    if (row == null) return true; // optimista mientras carga
    return switch (layer) {
      ShieldLayer.extorsion => row.extorsion,
      ShieldLayer.callcenter => row.callcenter,
      ShieldLayer.ley => row.ley,
    };
  }
}
