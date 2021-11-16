package net.kikuchy.plain_notification_token;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * PlainNotificationTokenPlugin
 */
public class PlainNotificationTokenPlugin extends BroadcastReceiver implements MethodCallHandler, FlutterPlugin {
    private Context context;
    private MethodChannel methodChannel;
    
    public PlainNotificationTokenPlugin() {}

    public static void registerWith(Registrar registrar) {
        new PlainNotificationTokenPlugin().onAttached(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {   
        onAttached(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        context = null;
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;

    }

    private void onAttached(Context applicationContext, BinaryMessenger messenger) {
        this.context = applicationContext;
        this.methodChannel = new MethodChannel(messenger, "plain_notification_token");
        methodChannel.setMethodCallHandler(this);
    }

    static final String TAG = PlainNotificationTokenPlugin.class.getSimpleName();

    private String lastToken = null;
    private MethodChannel channel;

    private PlainNotificationTokenPlugin(MethodChannel channel, Registrar registrar) {
        this.channel = channel;
        FirebaseApp.initializeApp(registrar.context());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getToken")) {
            FirebaseInstanceId.getInstance()
                    .getInstanceId()
                    .addOnCompleteListener(
                            new OnCompleteListener<InstanceIdResult>() {
                                @Override
                                public void onComplete(@NonNull Task<InstanceIdResult> task) {
                                    if (!task.isSuccessful()) {
                                        Log.w(TAG, "getToken, error fetching instanceID: ", task.getException());
                                        result.success(null);
                                        return;
                                    }

                                    result.success(task.getResult().getToken());
                                }
                            });
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();

        if (action == null) {
            return;
        }

        if (action.equals(NewTokenReceiveService.ACTION_TOKEN)) {
            String token = intent.getStringExtra(NewTokenReceiveService.EXTRA_TOKEN);
            channel.invokeMethod("onToken", token);
        }
    }
}
