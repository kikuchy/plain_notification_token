package net.kikuchy.plain_notification_token;

import android.content.Intent;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.google.firebase.messaging.FirebaseMessagingService;

public class NewTokenReceiveService extends FirebaseMessagingService {
    public static String ACTION_TOKEN = "ACTION_TOKEN";
    public static String EXTRA_TOKEN = "EXTRA_TOKEN";
    @Override
    public void onNewToken(String token) {
        final Intent intent = new Intent(ACTION_TOKEN);
        intent.putExtra(EXTRA_TOKEN, token);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }
}
