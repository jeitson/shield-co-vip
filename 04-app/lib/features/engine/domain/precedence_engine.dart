import 'package:shield_app/features/engine/domain/entities/block_decision.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';

/// Configuración de capas del escudo vista por el motor.
class EngineShieldConfig {
  const EngineShieldConfig({
    required this.extorsion,
    required this.callcenter,
    required this.ley,
  });

  final bool extorsion;
  final bool callcenter;
  final bool ley;

  bool isLayerActive(ShieldLayerKind layer) => switch (layer) {
    ShieldLayerKind.extorsion => extorsion,
    ShieldLayerKind.callcenter => callcenter,
    ShieldLayerKind.ley => ley,
  };
}

/// Índice de datos sobre el que decide el motor (hashes + config). No contiene
/// números legibles (RN-01). Es el mismo snapshot que se proyecta al nativo.
class EngineIndex {
  const EngineIndex({
    required this.whitelistLocal,
    required this.blacklistLocal,
    required this.allowlistGlobal,
    required this.blacklistGlobal,
    required this.categoryByHash,
    required this.config,
  });

  /// Hashes de la lista **blanca local** (nivel 1).
  final Set<String> whitelistLocal;

  /// Hashes de la lista **negra local** (nivel 3).
  final Set<String> blacklistLocal;

  /// Hashes de la **allowlist global** (nivel 2).
  final Set<String> allowlistGlobal;

  /// Hashes de la **negra global** (nivel 4) = dataset `phone_hashes`.
  final Set<String> blacklistGlobal;

  /// Categoría (RN-07) de cada hash de la negra global, para resolver qué capa
  /// la gobierna en el nivel 5.
  final Map<String, ThreatCategory> categoryByHash;

  /// Configuración vigente del escudo.
  final EngineShieldConfig config;
}

/// Motor de precedencia de **5 niveles** (`03-datos` §03.5). Lógica pura: dado
/// el hash del número entrante y el [EngineIndex], devuelve la decisión. Gana la
/// primera regla que coincide; si ninguna aplica, se permite por defecto.
abstract final class PrecedenceEngine {
  static BlockDecision decide(String hash, EngineIndex index) {
    // Nivel 1 — lista blanca local: el usuario es soberano, siempre pasa.
    if (index.whitelistLocal.contains(hash)) {
      return const BlockDecision(
        action: BlockAction.allow,
        level: PrecedenceLevel.whitelistLocal,
        reason: 'En lista blanca local (soberanía del usuario).',
      );
    }

    // Nivel 2 — allowlist global gestionada: entidad protegida, siempre pasa.
    if (index.allowlistGlobal.contains(hash)) {
      return const BlockDecision(
        action: BlockAction.allow,
        level: PrecedenceLevel.allowlistGlobal,
        reason: 'En allowlist global (entidad protegida).',
      );
    }

    // Nivel 3 — lista negra local: siempre bloquea.
    if (index.blacklistLocal.contains(hash)) {
      return const BlockDecision(
        action: BlockAction.block,
        level: PrecedenceLevel.blacklistLocal,
        reason: 'En lista negra local.',
      );
    }

    // Nivel 4+5 — negra global: bloquea solo si la capa responsable está activa.
    if (index.blacklistGlobal.contains(hash)) {
      final category = index.categoryByHash[hash];
      // Sin categoría conocida: tratar como negra global dura (nivel 4).
      if (category == null) {
        return const BlockDecision(
          action: BlockAction.block,
          level: PrecedenceLevel.blacklistGlobal,
          reason: 'En lista negra global (comunitaria).',
        );
      }
      // Nivel 5 — motor de capas: respeta RN-SHIELD-05 (capa off deja pasar).
      final layerActive = index.config.isLayerActive(category.layer);
      if (layerActive) {
        return BlockDecision(
          action: BlockAction.block,
          level: PrecedenceLevel.shieldLayers,
          reason: 'Amenaza "${category.label}"; capa activa → bloqueada.',
        );
      }
      return BlockDecision(
        action: BlockAction.allow,
        level: PrecedenceLevel.shieldLayers,
        reason:
            'Amenaza "${category.label}" pero su capa está desactivada → pasa.',
      );
    }

    // Ninguna regla aplicó → permitir por defecto (no romper llamadas legítimas).
    return BlockDecision.allowByDefault;
  }
}
