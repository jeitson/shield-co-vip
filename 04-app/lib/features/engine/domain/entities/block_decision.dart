/// Acción resultante del motor de precedencia.
enum BlockAction { allow, block }

/// Nivel de precedencia que determinó la decisión (para trazabilidad y UI).
enum PrecedenceLevel {
  /// Nivel 1: lista blanca local (soberanía del usuario).
  whitelistLocal,

  /// Nivel 2: allowlist global gestionada (entidad protegida).
  allowlistGlobal,

  /// Nivel 3: lista negra local del usuario.
  blacklistLocal,

  /// Nivel 4: lista negra global (dataset comunitario).
  blacklistGlobal,

  /// Nivel 5: motor de capas del escudo.
  shieldLayers,

  /// Ninguna regla aplicó → permitir por defecto.
  defaultAllow,
}

/// Decisión del motor sobre un contacto entrante, con la razón que la originó.
class BlockDecision {
  const BlockDecision({required this.action, required this.level, this.reason});

  final BlockAction action;
  final PrecedenceLevel level;

  /// Explicación legible/para log (sin exponer el número).
  final String? reason;

  bool get isBlocked => action == BlockAction.block;

  static const allowByDefault = BlockDecision(
    action: BlockAction.allow,
    level: PrecedenceLevel.defaultAllow,
    reason: 'Sin coincidencias; se permite por defecto.',
  );
}
