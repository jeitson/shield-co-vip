package com.cifradocero.shield_app.engine

import android.app.Activity
import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Puente MethodChannel entre Dart y la capa nativa del motor.
 *
 * Métodos:
 *  - writeSnapshot(json)         → persiste el snapshot que usa el matcher.
 *  - setPepper(pepper) / clearPepper()
 *  - requestCallScreeningRole()  → lanza el diálogo del SO (RoleManager).
 *  - permissionStatus()          → estado por capa (degradación honesta, §00.6).
 */
class BlockingEngineChannel(
    private val context: Context,
    private val snapshotStore: SnapshotStore,
    private val pepperStore: PepperStore,
) : MethodChannel.MethodCallHandler {

    /** Activity actual, necesaria para lanzar el diálogo de rol. */
    var activity: Activity? = null

    private var pendingRoleResult: MethodChannel.Result? = null

    companion object {
        const val CHANNEL = "cifradocero/engine"
        const val REQUEST_CALL_SCREENING_ROLE = 7801
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "writeSnapshot" -> {
                val json = call.arguments as? String
                if (json == null) {
                    result.error("bad_args", "snapshot json requerido", null)
                } else {
                    snapshotStore.write(json)
                    result.success(null)
                }
            }
            "setPepper" -> {
                val pepper = call.arguments as? String
                if (pepper == null) {
                    result.error("bad_args", "pepper requerido", null)
                } else {
                    pepperStore.setPepper(pepper)
                    result.success(null)
                }
            }
            "clearPepper" -> {
                pepperStore.clear()
                result.success(null)
            }
            "requestCallScreeningRole" -> requestCallScreeningRole(result)
            "permissionStatus" -> result.success(permissionStatus())
            else -> result.notImplemented()
        }
    }

    private fun requestCallScreeningRole(result: MethodChannel.Result) {
        val act = activity
        if (act == null) {
            result.error("no_activity", "sin activity para lanzar el rol", null)
            return
        }
        val roleManager = context.getSystemService(Context.ROLE_SERVICE) as RoleManager
        if (!roleManager.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
            result.success(false)
            return
        }
        if (roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)) {
            result.success(true)
            return
        }
        pendingRoleResult = result
        val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
        act.startActivityForResult(intent, REQUEST_CALL_SCREENING_ROLE)
    }

    /** Lo llama la Activity en onActivityResult. */
    fun onRoleResult(requestCode: Int, resultCode: Int): Boolean {
        if (requestCode != REQUEST_CALL_SCREENING_ROLE) return false
        pendingRoleResult?.success(resultCode == Activity.RESULT_OK)
        pendingRoleResult = null
        return true
    }

    private fun permissionStatus(): Map<String, Boolean> {
        val roleManager = context.getSystemService(Context.ROLE_SERVICE) as RoleManager
        val callScreening = roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
        val sms = ContextCompat.checkSelfPermission(
            context, android.Manifest.permission.RECEIVE_SMS,
        ) == PackageManager.PERMISSION_GRANTED
        val notifications = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                context, android.Manifest.permission.POST_NOTIFICATIONS,
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
        return mapOf(
            "callScreening" to callScreening,
            "sms" to sms,
            "notifications" to notifications,
        )
    }
}
