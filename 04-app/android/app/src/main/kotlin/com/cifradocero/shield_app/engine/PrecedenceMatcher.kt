package com.cifradocero.shield_app.engine

/** Decisión del motor nativo. */
enum class Decision { ALLOW, BLOCK }

/**
 * Resultado enriquecido de una evaluación: la decisión y, cuando bloquea por la
 * negra global, la **capa** responsable (`extorsion`/`callcenter`/`ley`) para
 * que el evento interceptado lleve contexto a Dart. `layer` es `null` cuando no
 * aplica (p. ej. negra local dura o allow).
 */
data class MatchResult(val decision: Decision, val layer: String?)

/**
 * Réplica nativa del motor de precedencia de 5 niveles (`03-datos` §03.5),
 * idéntica a `PrecedenceEngine` en Dart. Opera sobre el [Snapshot] proyectado.
 * O(1) por nivel (HashSet) para responder dentro de la ventana del SO.
 */
object PrecedenceMatcher {

    /** Decisión simple (compatibilidad con los call sites existentes). */
    fun decide(hash: String, snapshot: Snapshot): Decision =
        evaluate(hash, snapshot).decision

    /** Evaluación enriquecida con la capa responsable del bloqueo. */
    fun evaluate(hash: String, snapshot: Snapshot): MatchResult {
        // Nivel 1 — blanca local.
        if (snapshot.whitelistLocal.contains(hash)) return MatchResult(Decision.ALLOW, null)
        // Nivel 2 — allowlist global.
        if (snapshot.allowlistGlobal.contains(hash)) return MatchResult(Decision.ALLOW, null)
        // Nivel 3 — negra local.
        if (snapshot.blacklistLocal.contains(hash)) return MatchResult(Decision.BLOCK, "local")
        // Nivel 4+5 — negra global (respeta capa responsable).
        if (snapshot.blacklistGlobal.contains(hash)) {
            val layer = snapshot.layerByHash[hash]
                ?: return MatchResult(Decision.BLOCK, null) // sin categoría → negra global dura
            return if (snapshot.config.isLayerActive(layer)) {
                MatchResult(Decision.BLOCK, layer)
            } else {
                MatchResult(Decision.ALLOW, null) // RN-SHIELD-05: capa off deja pasar
            }
        }
        // Default: permitir.
        return MatchResult(Decision.ALLOW, null)
    }
}
