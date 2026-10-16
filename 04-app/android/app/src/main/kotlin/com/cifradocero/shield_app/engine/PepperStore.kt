package com.cifradocero.shield_app.engine

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

/**
 * Custodia del pepper del lado nativo, cifrado en reposo con una master key
 * respaldada por Android Keystore (`androidx.security`). El pepper lo entrega
 * Dart (que lo obtuvo de `v1-pepper`) por el MethodChannel; aquí lo necesitan el
 * CallScreeningService y el SmsReceiver, que corren fuera del engine Flutter y
 * no pueden leer el `flutter_secure_storage` de Dart.
 *
 * Coherente con `02-seguridad` §02.2: el pepper no vive en claro ni en la base;
 * aquí queda cifrado por el Keystore del dispositivo.
 */
class PepperStore(context: Context) {

    private val prefs = EncryptedSharedPreferences.create(
        context,
        "engine_secure_prefs",
        MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build(),
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
    )

    fun setPepper(pepper: String) {
        prefs.edit().putString(KEY_PEPPER, pepper).apply()
    }

    fun getPepper(): String? = prefs.getString(KEY_PEPPER, null)

    fun clear() {
        prefs.edit().remove(KEY_PEPPER).apply()
    }

    private companion object {
        const val KEY_PEPPER = "dataset_pepper"
    }
}
