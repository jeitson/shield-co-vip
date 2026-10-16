package com.cifradocero.shield_app.engine

import android.content.Context
import org.json.JSONObject
import java.io.File

/**
 * Persiste y lee el snapshot del motor que proyecta Dart (ver spec 05 §1).
 *
 * El snapshot contiene solo hashes opacos + config (nunca números legibles,
 * RN-01). Se guarda como archivo privado de la app para que el
 * [CallScreeningServiceImpl] y el [SmsReceiver] —que corren fuera del engine
 * Dart— puedan decidir sin arrancar Flutter.
 */
class SnapshotStore(context: Context) {

    private val file = File(context.filesDir, "engine_snapshot.json")

    fun write(json: String) {
        file.writeText(json)
    }

    /** Lee el snapshot actual o `null` si aún no se proyectó. */
    fun read(): Snapshot? {
        if (!file.exists()) return null
        return try {
            parse(JSONObject(file.readText()))
        } catch (_: Exception) {
            null
        }
    }

    private fun parse(o: JSONObject): Snapshot {
        fun set(key: String): Set<String> {
            val arr = o.optJSONArray(key) ?: return emptySet()
            val out = HashSet<String>(arr.length())
            for (i in 0 until arr.length()) out.add(arr.getString(i))
            return out
        }

        val layerByHash = HashMap<String, String>()
        o.optJSONObject("layerByHash")?.let { obj ->
            val keys = obj.keys()
            while (keys.hasNext()) {
                val k = keys.next()
                layerByHash[k] = obj.getString(k)
            }
        }

        val cfg = o.optJSONObject("config") ?: JSONObject()
        return Snapshot(
            whitelistLocal = set("whitelistLocal"),
            blacklistLocal = set("blacklistLocal"),
            allowlistGlobal = set("allowlistGlobal"),
            blacklistGlobal = set("blacklistGlobal"),
            layerByHash = layerByHash,
            config = ShieldConfig(
                extorsion = cfg.optBoolean("extorsion", true),
                callcenter = cfg.optBoolean("callcenter", true),
                ley = cfg.optBoolean("ley", true),
            ),
        )
    }
}

data class ShieldConfig(
    val extorsion: Boolean,
    val callcenter: Boolean,
    val ley: Boolean,
) {
    fun isLayerActive(layer: String): Boolean = when (layer) {
        "extorsion" -> extorsion
        "callcenter" -> callcenter
        "ley" -> ley
        else -> true
    }
}

data class Snapshot(
    val whitelistLocal: Set<String>,
    val blacklistLocal: Set<String>,
    val allowlistGlobal: Set<String>,
    val blacklistGlobal: Set<String>,
    val layerByHash: Map<String, String>,
    val config: ShieldConfig,
)
