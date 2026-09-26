package com.pirci.prayer_assistant

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver

object ReminderNotificationManager {
    const val CHANNEL_ID = "prayer_reminders_chime_vibrate_sound"
    const val CHANNEL_NAME = "Prayer Reminders (vibrate + sound)"
    const val ACTION_REMINDER_DISMISSED = "com.pirci.prayer_assistant.ACTION_REMINDER_DISMISSED"
    const val ACTION_REMINDER_ALARM = "com.pirci.prayer_assistant.ACTION_REMINDER_ALARM"

    private val handledActions = java.util.concurrent.ConcurrentHashMap<Int, Long>()

    fun markActionHandled(id: Int) {
        handledActions[id] = System.currentTimeMillis()
    }

    fun isActionRecentlyHandled(id: Int): Boolean {
        val time = handledActions[id] ?: return false
        if (System.currentTimeMillis() - time < 3000L) {
            return true
        }
        handledActions.remove(id)
        return false
    }

    fun show(
        context: Context,
        id: Int,
        title: String,
        body: String,
        payload: String? = null,
        snoozeLabel: String = "Snooze",
        dismissLabel: String = "Dismiss",
        doneLabel: String = "Done",
        soundResource: String? = "reminder_chime"
    ) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val existing = manager.getNotificationChannel(CHANNEL_ID)
            if (existing == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Prayer reminder notifications"
                    enableVibration(true)
                    vibrationPattern = longArrayOf(0, 500, 1000, 500, 1000, 500, 1000)
                    if (soundResource != null) {
                        val soundUri = Uri.parse("android.resource://${context.packageName}/raw/$soundResource")
                        val audioAttributes = AudioAttributes.Builder()
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                            .build()
                        setSound(soundUri, audioAttributes)
                    }
                }
                manager.createNotificationChannel(channel)
            }
        }

        val contentIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("notification_id", id)
            putExtra("payload", payload)
        }
        val contentPendingIntent = PendingIntent.getActivity(
            context,
            id * 10,
            contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Delete intent triggered by OS when the notification is swiped away.
        // Causes ReminderDismissReceiver to immediately reopen the notification.
        val dismissIntent = Intent(context, ReminderDismissReceiver::class.java).apply {
            action = ACTION_REMINDER_DISMISSED
            putExtra("id", id)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("payload", payload)
            putExtra("snoozeLabel", snoozeLabel)
            putExtra("dismissLabel", dismissLabel)
            putExtra("doneLabel", doneLabel)
            putExtra("soundResource", soundResource)
        }
        val deletePendingIntent = PendingIntent.getBroadcast(
            context,
            id * 10 + 9,
            dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        fun buildActionPendingIntent(actionId: String): PendingIntent {
            val actionIntent = Intent(context, ReminderActionReceiver::class.java).apply {
                action = ReminderActionReceiver.ACTION_REMINDER_ACTION
                putExtra("actionId", actionId)
                putExtra("id", id)
                putExtra("title", title)
                putExtra("body", body)
                putExtra("payload", payload)
                putExtra("snoozeLabel", snoozeLabel)
                putExtra("dismissLabel", dismissLabel)
                putExtra("doneLabel", doneLabel)
                putExtra("soundResource", soundResource)
            }
            val actionOffset = when (actionId) {
                "action_snooze" -> 1
                "action_dismiss" -> 2
                "action_done" -> 3
                else -> 4
            }
            return PendingIntent.getBroadcast(
                context,
                id * 10 + actionOffset,
                actionIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val snoozePendingIntent = buildActionPendingIntent("action_snooze")
        val dismissActionPendingIntent = buildActionPendingIntent("action_dismiss")
        val donePendingIntent = buildActionPendingIntent("action_done")

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(false)
            .setOngoing(true)
            .setContentIntent(contentPendingIntent)
            .setDeleteIntent(deletePendingIntent)
            .addAction(0, snoozeLabel, snoozePendingIntent)
            .addAction(0, dismissLabel, dismissActionPendingIntent)
            .addAction(0, doneLabel, donePendingIntent)

        val notification = builder.build()
        notification.flags = notification.flags or 32 // FLAG_NO_CLEAR

        NotificationManagerCompat.from(context).notify(id, notification)
    }

    fun schedule(
        context: Context,
        id: Int,
        triggerAtMillis: Long,
        title: String,
        body: String,
        payload: String? = null,
        snoozeLabel: String = "Snooze",
        dismissLabel: String = "Dismiss",
        doneLabel: String = "Done",
        soundResource: String? = "reminder_chime"
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, ReminderAlarmReceiver::class.java).apply {
            action = ACTION_REMINDER_ALARM
            putExtra("id", id)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("payload", payload)
            putExtra("snoozeLabel", snoozeLabel)
            putExtra("dismissLabel", dismissLabel)
            putExtra("doneLabel", doneLabel)
            putExtra("soundResource", soundResource)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id * 10 + 8,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
        }
    }

    fun cancel(context: Context, id: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, ReminderAlarmReceiver::class.java).apply {
            action = ACTION_REMINDER_ALARM
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id * 10 + 8,
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        if (pendingIntent != null) {
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
        }
        NotificationManagerCompat.from(context).cancel(id)
    }
}
