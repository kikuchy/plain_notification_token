package net.kikuchy.plain_notification_token

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import com.google.firebase.FirebaseApp
import com.google.firebase.iid.FirebaseInstanceId
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** PlainNotificationTokenPlugin */
class PlainNotificationTokenPlugin : BroadcastReceiver(), FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    companion object {
        const val TAG: String = "PlainNotificationToken"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        if (FirebaseApp.getApps(context).isEmpty()) {
            FirebaseApp.initializeApp(context)
        }

        channel = MethodChannel(binding.binaryMessenger, "plain_notification_token")
        channel.setMethodCallHandler(this)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(
                this,
                IntentFilter(NewTokenReceiveService.ACTION_TOKEN),
                Context.RECEIVER_NOT_EXPORTED
            )
        } else {
            context.registerReceiver(
                this,
                IntentFilter(NewTokenReceiveService.ACTION_TOKEN)
            )
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getToken") {
            FirebaseInstanceId.getInstance()
                .instanceId
                .addOnCompleteListener { task ->
                    if (!task.isSuccessful || task.result == null) {
                        Log.w(TAG, "getToken, error fetching instanceID: ", task.exception)
                        result.success(null)
                        return@addOnCompleteListener
                    }
                    result.success(task.result?.token)
                }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context.unregisterReceiver(this)
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == NewTokenReceiveService.ACTION_TOKEN) {
            val token = intent.getStringExtra(NewTokenReceiveService.EXTRA_TOKEN)
            channel.invokeMethod("onToken", token)
        }
    }
}