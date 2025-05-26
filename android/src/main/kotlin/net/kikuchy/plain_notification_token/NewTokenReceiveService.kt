package net.kikuchy.plain_notification_token

import android.content.Intent
import com.google.firebase.messaging.FirebaseMessagingService

class NewTokenReceiveService : FirebaseMessagingService() {
    override fun onNewToken(token: String) {
        val intent = Intent(ACTION_TOKEN).apply {
            putExtra(EXTRA_TOKEN, token)
        }

        sendBroadcast(intent)
    }

    companion object {
        const val ACTION_TOKEN = "net.kikuchy.plain_notification_token.ACTION_TOKEN"
        const val EXTRA_TOKEN = "EXTRA_TOKEN"
    }
}
