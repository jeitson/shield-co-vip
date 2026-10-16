package com.cifradocero.shield_app.engine

/** Decisión del motor nativo. */
enum class Decision { ALLOW, BLOCK }

/**
 * Réplica nativa del motor de precedencia de 5 niveles (`03-datos` §03.5),
 * idéntica a `PrecedenceEngine` en Dart. Opera sobre el [Snapshot] proyectado.
 * O(1) por nivel (HashSet) para responder dentro de la ventana del SO.
 */
object PrecedenceMatcher {

    fun decide(hash: String, snapshot: Snapshot): Decision {
        // Nivel 1 — blanca local.
        if (snapshot.whitelistLocal.contains(hash)) return Decision.ALLOW
        // Nivel 2 — allowlist global.
        if (snapshot.allowlistGlobal.contains(hash)) return Decision.ALLOW
        // Nivel 3 — negra local.
        if (snapshot.blacklistLocal.contains(hash)) return Decision.BLOCK
        // Nivel 4+5 — negra global (respeta capa responsable).
        if (snapshot.blacklistGlobal.contains(hash)) {
            val layer = snapshot.layerByHash[hash]
                ?: return Decision.BLOCK // sin categoría → negra global dura
            return if (snapshot.config.isLayerActive(layer)) {
                Decision.BLOCK
            } else {
                Decision.ALLOW // RN-SHIELD-05: capa off deja pasar
            }
        }
        // Default: permitir.
        return Decision.ALLOW
    }
}
