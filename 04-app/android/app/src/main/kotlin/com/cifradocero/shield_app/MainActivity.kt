package com.cifradocero.shield_app

import android.content.Intent
import android.provider.Settings
import com.cifradocero.shield_app.engine.BlockingEngineChannel
import com.cifradocero.shield_app.engine.PepperStore
import com.cifradocero.shield_app.engine.SnapshotStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var engineChannel: BlockingEngineChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = BlockingEngineChannel(
            context = applicationContext,
            snapshotStore = SnapshotStore(applicationContext),
            pepperStore = PepperStore(applicationContext),
        )
        channel.activity = this
        engineChannel = channel

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BlockingEngineChannel.CHANNEL,
        ).setMethodCallHandler(channel)

        // Canal para el identificador estable del dispositivo (ANDROID_ID).
        // ANDROID_ID sobrevive a reinstalaciones (misma firma + mismo usuario),
        // no requiere permisos y NO es IMEI/serial. Se usa solo para derivar un
        // device_id estable en Dart (UUID v5), nunca se envía en crudo (DA-02).
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PLATFORM_DEVICE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidId" -> {
                    val androidId = Settings.Secure.getString(
                        contentResolver,
                        Settings.Secure.ANDROID_ID,
                    )
                    result.success(androidId)
                }
                else -> result.notImplemented()
            }
        }
    }

    companion object {
        private const val PLATFORM_DEVICE_CHANNEL =
            "com.cifradocero.shield_app/platform_device"
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (engineChannel?.onRoleResult(requestCode, resultCode) != true) {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }
}
