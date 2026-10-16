package com.cifradocero.shield_app

import android.content.Intent
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
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (engineChannel?.onRoleResult(requestCode, resultCode) != true) {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }
}
