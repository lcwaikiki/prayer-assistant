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
        val showDone = intent.getBooleanExtra("showDone", false)
        val soundResource = intent.getStringExtra("soundResource")
        val originalTime = intent.getStringExtra("originalTime")
        if (payload?.contains("\"type\":\"prayer\"") == true) {
            ReminderNotificationManager.markActionHandled(id)
            ReminderNotificationManager.cancel(context, id)
            return
        }
        val dismissConfirm = PrayerWidgetStorage.readDismissConfirm(context) && intent.getBooleanExtra("dismissConfirm", true)
        if (!dismissConfirm) {
            ReminderNotificationManager.markActionHandled(id)
            ReminderNotificationManager.cancel(context, id)
            return
        }

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
                    showDone = showDone,
                    soundResource = soundResource,
                    originalTime = originalTime,
                    dismissConfirm = dismissConfirm
                )
            } finally {
                pendingResult.finish()
            }
        }, 150L)
    }
}
