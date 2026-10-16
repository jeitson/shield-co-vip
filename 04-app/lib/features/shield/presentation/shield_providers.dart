import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/db/daos/shield_config_dao.dart';
import 'package:shield_app/core/db/db_providers.dart';
import 'package:shield_app/core/platform/blocking_engine.dart';
import 'package:shield_app/core/platform/blocking_engine_android.dart';
import 'package:shield_app/features/shield/domain/shield_status.dart';

/// Configuración del escudo observada en vivo (reactiva, de la base cifrada).
final shieldConfigProvider = StreamProvider<ShieldConfigRow>((ref) async* {
  final dao = await ref.watch(shieldConfigDaoProvider.future);
  yield* dao.watchConfig();
});

/// Número de capas activas (0–3) derivado de la config.
final activeLayerCountProvider = Provider<int>((ref) {
  final config = ref.watch(shieldConfigProvider).valueOrNull;
  if (config == null) return 3; // optimista mientras carga (defecto protegido)
  var n = 0;
  if (config.extorsion) n++;
  if (config.callcenter) n++;
  if (config.ley) n++;
  return n;
});

/// Estado agregado del escudo (RN-03).
final shieldStatusProvider = Provider<ShieldStatus>(
  (ref) => ShieldStatus.fromActiveCount(ref.watch(activeLayerCountProvider)),
);

/// Controlador de acciones del escudo (toggle de capas).
final shieldControllerProvider = Provider<ShieldController>(
  (ref) => ShieldController(ref),
);

class ShieldController {
  ShieldController(this._ref);
  final Ref _ref;

  /// Alterna una capa: persiste en la base (A) → el stream recalcula el estado →
  /// `engineIndexProvider` se recomputa y `engineProjectionProvider` reproyecta
  /// al motor (C), haciendo real RF-SHIELD-04.
  Future<void> toggleLayer(ShieldLayer layer, bool enabled) async {
    final dao = await _ref.read(shieldConfigDaoProvider.future);
    await dao.setLayer(layer, enabled);
  }

  /// Solicita el rol de filtrado de llamadas (y permisos asociados) al SO y
  /// refresca el estado de permisos para que el priming desaparezca si se
  /// concede (degradación honesta, §00.6).
  Future<void> requestCallScreening() async {
    await _ref.read(blockingEngineProvider).requestPermissions();
    _ref.invalidate(enginePermissionsProvider);
  }
}

// --- Permisos del motor (degradación honesta, §00.6) ---

/// Instancia del motor según plataforma (Android real / no-op).
final blockingEngineProvider = Provider<BlockingEngine>(
  (ref) => createBlockingEngine(),
);

/// Estado de permisos del motor (llamadas/SMS/notificaciones). Refrescable al
/// reanudar la pantalla (invalidando este provider).
final enginePermissionsProvider = FutureProvider<EnginePermissionStatus>(
  (ref) => ref.watch(blockingEngineProvider).permissionStatus(),
);
