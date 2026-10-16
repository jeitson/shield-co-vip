import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shield_app/core/platform/blocking_engine.dart';

/// Implementación real de [BlockingEngine] para Android sobre el MethodChannel
/// `cifradocero/engine` (ver `BlockingEngineChannel.kt`).
///
/// La decisión en caliente (bloquear/permitir) ocurre **en nativo** con el
/// snapshot proyectado; esta clase cubre la gestión de roles/permisos y el
/// estado. El `decide` explícito queda disponible para flujos manuales/pruebas.
///
/// En plataformas que no son Android, usar [BlockingEngineNoop] (degradación:
/// reporta permisos en falso y no intercepta).
class BlockingEngineAndroid implements BlockingEngine {
  BlockingEngineAndroid([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('cifradocero/engine');

  final MethodChannel _channel;

  @override
  Future<bool> requestPermissions() async {
    // Solicita el rol de call screening (el más crítico). Los permisos runtime
    // de SMS/notificaciones se piden desde el flujo de priming con permission
    // handlers de Flutter o Activity result.
    final granted = await _channel.invokeMethod<bool>(
      'requestCallScreeningRole',
    );
    return granted ?? false;
  }

  @override
  Future<EnginePermissionStatus> permissionStatus() async {
    final map = await _channel.invokeMapMethod<String, dynamic>(
      'permissionStatus',
    );
    return EnginePermissionStatus(
      callScreeningGranted: (map?['callScreening'] as bool?) ?? false,
      smsGranted: (map?['sms'] as bool?) ?? false,
      notificationsGranted: (map?['notifications'] as bool?) ?? false,
    );
  }

  @override
  Stream<IncomingContact> get incoming => const Stream.empty();

  @override
  Future<void> decide(String contactId, BlockDecision decision) async {
    // La decisión en caliente la toma el servicio nativo con el snapshot; no se
    // enruta por aquí en el MVP. Reservado para decisiones manuales.
  }
}

/// Implementación nula para plataformas sin motor nativo (iOS por ahora,
/// escritorio, tests). Degradación honesta: nada está protegido.
class BlockingEngineNoop implements BlockingEngine {
  const BlockingEngineNoop();

  @override
  Future<bool> requestPermissions() async => false;

  @override
  Future<EnginePermissionStatus> permissionStatus() async =>
      const EnginePermissionStatus(
        callScreeningGranted: false,
        smsGranted: false,
        notificationsGranted: false,
      );

  @override
  Stream<IncomingContact> get incoming => const Stream.empty();

  @override
  Future<void> decide(String contactId, BlockDecision decision) async {}
}

/// Selecciona la implementación real según plataforma.
BlockingEngine createBlockingEngine() {
  if (Platform.isAndroid) return BlockingEngineAndroid();
  return const BlockingEngineNoop();
}
