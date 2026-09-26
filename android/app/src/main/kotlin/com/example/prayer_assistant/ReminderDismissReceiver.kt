package com.pirci.prayer_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper

class ReminderDismissReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return
        val id = intent.getIntExtra("id", 0)
        if (ReminderNotificationManager.isActionRecentlyHandled(id)) return
        val title = intent.getStringExtra("title") ?: "Reminder"
        val body = intent.getStringExtra("body") ?: ""
        val payload = intent.getStringExtra("payload")
        val snoozeLabel = intent.getStringExtra("snoozeLabel") ?: "Snooze"
        val dismissLabel = intent.getStringExtra("dismissLabel") ?: "Dismiss"
        val doneLabel = intent.getStringExtra("doneLabel") ?: "Done"
        val soundResource = intent.getStringExtra("soundResource")

        val pendingResult = goAsync()
        Handler(Looper.getMainLooper()).postDelayed({
            try {
                ReminderNotificationManager.show(
                    context = context,
                    id = id,
                    title = title,
                    body = body,
                    payload = payload,
                    snoozeLabel = snoozeLabel,
                    dismissLabel = dismissLabel,
                    doneLabel = doneLabel,
                    soundResource = soundResource
                )
            } finally {
                pendingResult.finish()
            }
        }, 150L)
    }
}
