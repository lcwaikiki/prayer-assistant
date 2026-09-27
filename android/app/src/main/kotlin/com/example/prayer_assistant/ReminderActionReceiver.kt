package com.pirci.prayer_assistant

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat
import com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver

class ReminderActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_REMINDER_ACTION = "com.pirci.prayer_assistant.ACTION_REMINDER_ACTION"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return
        val actionId = intent.getStringExtra("actionId") ?: return
        val id = intent.getIntExtra("id", 0)
        val title = intent.getStringExtra("title") ?: "Reminder"
        val body = intent.getStringExtra("body") ?: ""
        val payload = intent.getStringExtra("payload")
        val snoozeLabel = intent.getStringExtra("snoozeLabel") ?: "Snooze"
        val dismissLabel = intent.getStringExtra("dismissLabel") ?: "Dismiss"
        val doneLabel = intent.getStringExtra("doneLabel") ?: "Done"
        val soundResource = intent.getStringExtra("soundResource")

        when (actionId) {
            "action_snooze" -> {
                ReminderNotificationManager.showSnoozeOptions(
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
            }
            "action_snooze_pick" -> {
                ReminderNotificationManager.markActionHandled(id)
                NotificationManagerCompat.from(context).cancel(id)

                val snoozeMinutes = intent.getIntExtra("snoozeMinutes", 10).let {
                    if (it <= 0) 10 else it
                }
                val triggerAtMillis = System.currentTimeMillis() + (snoozeMinutes * 60 * 1000L)
                ReminderNotificationManager.schedule(
                    context = context,
                    id = id,
                    triggerAtMillis = triggerAtMillis,
                    title = title,
                    body = body,
                    payload = payload,
                    snoozeLabel = snoozeLabel,
                    dismissLabel = dismissLabel,
                    doneLabel = doneLabel,
                    soundResource = soundResource
                )
            }
            "action_dismiss" -> {
                ReminderNotificationManager.markActionHandled(id)
                NotificationManagerCompat.from(context).cancel(id)
                ReminderNotificationManager.cancel(context, id)
            }
            "action_done" -> {
                ReminderNotificationManager.markActionHandled(id)
                NotificationManagerCompat.from(context).cancel(id)
                ReminderNotificationManager.cancel(context, id)
                val flutterIntent = Intent(context, ActionBroadcastReceiver::class.java).apply {
                    action = ActionBroadcastReceiver.ACTION_TAPPED
                    putExtra("notificationId", id)
                    putExtra("actionId", "action_done")
                    putExtra("payload", payload)
                    putExtra("cancelNotification", true)
                }
                context.sendBroadcast(flutterIntent)
            }
        }
    }
}
