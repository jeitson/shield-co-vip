package com.cifradocero.shield_app.engine

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/**
 * Cola **persistente** de interceptaciones producidas por el nativo
 * (`CallScreeningServiceImpl`, `SmsReceiver`), que corren en procesos sin un
 * FlutterEngine vivo. No se puede empujar el evento a Dart en caliente (la UI
 * puede estar cerrada), así que se **encola en disco** y Dart la **drena** al
 * arrancar/reanudar vía el MethodChannel (`drainEvents`).
 *
 * Solo se guarda el mínimo crudo: número + canal + body (SMS) + timestamp. Dart
 * rehidrata el resto (categoría/nivel/título) con el `EngineIndex`. El archivo
 * vive en `filesDir` (privado de la app); el número en claro no sale del
 * dispositivo (RN-01) y se borra al drenar.
 *
 * Diseño simple y robusto: un archivo JSON con un array. Acceso sincronizado a
 * nivel de clase para evitar carreras entre el servicio de llamadas y el
 * receiver de SMS. El volumen esperado es bajo (una interceptación a la vez).
 */
class EventQueueStore(context: Context) {

    private val file = File(context.filesDir, "intercepted_events_queue.json")

    /** Añade un evento interceptado a la cola. */
    fun enqueue(
        rawNumber: String,
        channel: String,
        layer: String?,
        body: String?,
    ) {
        synchronized(LOCK) {
            val arr = readArray()
            val obj = JSONObject().apply {
                put("rawNumber", rawNumber)
                put("channel", channel) // "call" | "sms"
                put("layer", layer ?: JSONObject.NULL) // extorsion/callcenter/ley
                put("body", body ?: JSONObject.NULL)
                put("timestampMs", System.currentTimeMillis())
            }
            arr.put(obj)
            file.writeText(arr.toString())
        }
    }

    /**
     * Devuelve todos los eventos encolados como lista de mapas y **vacía** la
     * cola de forma atómica. Pensado para que Dart lo invoque una vez y persista
     * los eventos en su base cifrada.
     */
    fun drain(): List<Map<String, Any?>> {
        synchronized(LOCK) {
            if (!file.exists()) return emptyList()
            val arr = readArray()
            val out = ArrayList<Map<String, Any?>>(arr.length())
            for (i in 0 until arr.length()) {
                val o = arr.optJSONObject(i) ?: continue
                out.add(
                    mapOf(
                        "rawNumber" to o.optString("rawNumber"),
                        "channel" to o.optString("channel"),
                        "layer" to if (o.isNull("layer")) null else o.optString("layer"),
                        "body" to if (o.isNull("body")) null else o.optString("body"),
                        "timestampMs" to o.optLong("timestampMs"),
                    ),
                )
            }
            // Vaciar la cola tras leerla.
            file.delete()
            return out
        }
    }

    private fun readArray(): JSONArray {
        if (!file.exists()) return JSONArray()
        return try {
            JSONArray(file.readText())
        } catch (_: Exception) {
            JSONArray()
        }
    }

    private companion object {
        val LOCK = Any()
    }
}
