import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shield_app/features/engine/domain/precedence_engine.dart';

/// Proyecta el [EngineIndex] a la capa nativa Android para que el
/// `CallScreeningService` (que corre fuera del engine Dart) pueda decidir con la
/// misma precedencia y datos (ver spec 05 §1).
///
/// Solo viaja material opaco (hashes) y la config; nunca números legibles
/// (RN-01). El pepper no se envía: el nativo lo lee del keystore.
class NativeSnapshotWriter {
  NativeSnapshotWriter([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('cifradocero/engine');

  final MethodChannel _channel;

  /// Serializa el índice y lo entrega al nativo (`writeSnapshot`).
  Future<void> project(EngineIndex index) async {
    final payload = encode(index);
    await _channel.invokeMethod<void>('writeSnapshot', payload);
  }

  /// Entrega el pepper al nativo para que hashee el número entrante. El nativo
  /// lo guarda cifrado (EncryptedSharedPreferences). Nunca viaja un número.
  Future<void> setPepper(String pepper) async {
    await _channel.invokeMethod<void>('setPepper', pepper);
  }

  /// Borra el pepper del lado nativo (logout / revocación).
  Future<void> clearPepper() async {
    await _channel.invokeMethod<void>('clearPepper');
  }

  /// Serialización estable del snapshot (expuesta para pruebas).
  static String encode(EngineIndex index) {
    return jsonEncode({
      'version': 1,
      'whitelistLocal': index.whitelistLocal.toList(),
      'blacklistLocal': index.blacklistLocal.toList(),
      'allowlistGlobal': index.allowlistGlobal.toList(),
      'blacklistGlobal': index.blacklistGlobal.toList(),
      // categoría→capa por hash, para respetar RN-SHIELD-05 nativamente.
      'layerByHash': {
        for (final e in index.categoryByHash.entries) e.key: e.value.layer.name,
      },
      'config': {
        'extorsion': index.config.extorsion,
        'callcenter': index.config.callcenter,
        'ley': index.config.ley,
      },
    });
  }
}
