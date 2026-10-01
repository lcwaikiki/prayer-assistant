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
import android.widget.RemoteViews
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

    private fun getOriginalTimeLabel(snoozeLabel: String): String {
        return when (snoozeLabel.lowercase(java.util.Locale.ROOT)) {
            "ertele" -> "Asıl saat"
            "غفوة" -> "الوقت الأصلي"
            "schlummern" -> "Ursprüngliche Zeit"
            "posponer" -> "Hora original"
            "rappeler" -> "Heure d'origine"
            "به تعویق انداختن" -> "زمان اصلی"
            "توقف" -> "اصل وقت"
            "tunda" -> "Waktu asli"
            "отложить" -> "Исходное время"
            else -> "Original time"
        }
    }

    private fun getDismissPrompt(snoozeLabel: String): String {
        return when (snoozeLabel.lowercase(java.util.Locale.ROOT)) {
            "ertele" -> "Kapatmak istediğinizden emin misiniz?"
            "غفوة" -> "هل أنت متأكد أنك تريد الإغلاق؟"
            "schlummern" -> "Möchten Sie wirklich schließen?"
            "posponer" -> "¿Seguro que desea descartar?"
            "rappeler" -> "Voulez-vous vraiment fermer ?"
            "به تعویق انداختن" -> "آیا مطمئن هستید که می‌خواهید ببندید؟"
            "توقف" -> "کیا آپ واقعی بند کرنا چاہتے ہیں؟"
            "tunda" -> "Apakah Anda yakin ingin menutup?"
            "отложить" -> "Вы уверены, что хотите закрыть?"
            else -> "Are you sure you want to dismiss?"
        }
    }

    private fun getCancelLabel(snoozeLabel: String): String {
        return when (snoozeLabel.lowercase(java.util.Locale.ROOT)) {
            "ertele" -> "İptal"
            "غفوة" -> "إلغاء"
            "schlummern" -> "Abbrechen"
            "posponer" -> "Cancelar"
            "rappeler" -> "Annuler"
            "به تعویق انداختن" -> "انصراف"
            "توقف" -> "منسوخ"
            "tunda" -> "Batal"
            "отложить" -> "Отмена"
            else -> "Cancel"
        }
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
        showDone: Boolean = false,
        soundResource: String? = "reminder_chime",
        originalTime: String? = null,
        dismissConfirm: Boolean = true
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

        handledActions.remove(id)

        val contentIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("notification_id", id)
            putExtra("payload", payload)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("snoozeLabel", snoozeLabel)
            putExtra("dismissLabel", dismissLabel)
            putExtra("doneLabel", doneLabel)
            putExtra("showDone", showDone)
            putExtra("soundResource", soundResource)
            putExtra("originalTime", originalTime)
            putExtra("dismissConfirm", dismissConfirm)
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
            data = Uri.parse("reminder://dismiss/$id/${System.currentTimeMillis()}")
            putExtra("id", id)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("payload", payload)
            putExtra("snoozeLabel", snoozeLabel)
            putExtra("dismissLabel", dismissLabel)
            putExtra("doneLabel", doneLabel)
            putExtra("showDone", showDone)
            putExtra("soundResource", soundResource)
            putExtra("originalTime", originalTime)
            putExtra("dismissConfirm", dismissConfirm)
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
                putExtra("showDone", showDone)
                putExtra("soundResource", soundResource)
                putExtra("originalTime", originalTime)
                putExtra("dismissConfirm", dismissConfirm)
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

        val origLabel = getOriginalTimeLabel(snoozeLabel)
        val origText = if (!originalTime.isNullOrEmpty()) "$origLabel: $originalTime" else null

        val collapsedRemoteViews = RemoteViews(context.packageName, R.layout.notification_reminder_initial).apply {
            setTextViewText(R.id.reminderTitle, title)
            setTextViewText(R.id.reminderBody, body)
            if (origText != null) {
                setTextViewText(R.id.reminderOriginalTime, origText)
                setViewVisibility(R.id.reminderOriginalTime, android.view.View.VISIBLE)
            } else {
                setViewVisibility(R.id.reminderOriginalTime, android.view.View.GONE)
            }
            setViewVisibility(R.id.reminderActionsContainer, android.view.View.GONE)
        }

        val expandedRemoteViews = RemoteViews(context.packageName, R.layout.notification_reminder_initial).apply {
            setTextViewText(R.id.reminderTitle, title)
            setTextViewText(R.id.reminderBody, body)
            if (origText != null) {
                setTextViewText(R.id.reminderOriginalTime, origText)
                setViewVisibility(R.id.reminderOriginalTime, android.view.View.VISIBLE)
            } else {
                setViewVisibility(R.id.reminderOriginalTime, android.view.View.GONE)
            }
            setTextViewText(R.id.btnReminderSnooze, snoozeLabel)
            setTextViewText(R.id.btnReminderDismiss, dismissLabel)
            setTextViewText(R.id.btnReminderDone, doneLabel)

            setViewVisibility(R.id.reminderActionsContainer, android.view.View.VISIBLE)
            setViewVisibility(R.id.btnReminderDone, if (showDone) android.view.View.VISIBLE else android.view.View.GONE)

            setOnClickPendingIntent(R.id.btnReminderSnooze, snoozePendingIntent)
            setOnClickPendingIntent(R.id.btnReminderDismiss, dismissActionPendingIntent)
            if (showDone) {
                setOnClickPendingIntent(R.id.btnReminderDone, donePendingIntent)
            }
        }

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(false)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(contentPendingIntent)
            .setDeleteIntent(deletePendingIntent)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(collapsedRemoteViews)
            .setCustomBigContentView(expandedRemoteViews)

        val notification = builder.build()
        notification.flags = notification.flags or 34 // FLAG_ONGOING_EVENT (2) or FLAG_NO_CLEAR (32)

        NotificationManagerCompat.from(context).notify(id, notification)
    }

    fun showSnoozeOptions(
        context: Context,
        id: Int,
        title: String,
        body: String,
        payload: String? = null,
        snoozeLabel: String = "Snooze",
        dismissLabel: String = "Dismiss",
        doneLabel: String = "Done",
        showDone: Boolean = false,
        soundResource: String? = "reminder_chime",
        originalTime: String? = null,
        dismissConfirm: Boolean = true
    ) {
        handledActions.remove(id)

        val contentIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("notification_id", id)
            putExtra("payload", payload)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("snoozeLabel", snoozeLabel)
            putExtra("dismissLabel", dismissLabel)
            putExtra("doneLabel", doneLabel)
            putExtra("showDone", showDone)
            putExtra("soundResource", soundResource)
            putExtra("originalTime", originalTime)
            putExtra("dismissConfirm", dismissConfirm)
        }
        val contentPendingIntent = PendingIntent.getActivity(
            context,
            id * 10,
            contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // If swiped away while showing options, re-show original notification
        val dismissIntent = Intent(context, ReminderDismissReceiver::class.java).apply {
            action = ACTION_REMINDER_DISMISSED
            data = Uri.parse("reminder://dismiss/$id/${System.currentTimeMillis()}")
            putExtra("id", id)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("payload", payload)
            putExtra("snoozeLabel", snoozeLabel)
            putExtra("dismissLabel", dismissLabel)
            putExtra("doneLabel", doneLabel)
            putExtra("showDone", showDone)
            putExtra("soundResource", soundResource)
            putExtra("originalTime", originalTime)
            putExtra("dismissConfirm", dismissConfirm)
        }
        val deletePendingIntent = PendingIntent.getBroadcast(
            context,
            id * 10 + 9,
            dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val isTr = snoozeLabel.equals("Ertele", ignoreCase = true)
        val promptText = if (isTr) "Erteleme süresini seçin:" else "Choose snooze duration:"

        fun buildSnoozeChoicePendingIntent(minutes: Int, offset: Int): PendingIntent {
            val intent = Intent(context, ReminderActionReceiver::class.java).apply {
                action = ReminderActionReceiver.ACTION_REMINDER_ACTION
                putExtra("actionId", "action_snooze_pick")
                putExtra("snoozeMinutes", minutes)
                putExtra("id", id)
                putExtra("title", title)
                putExtra("body", body)
                putExtra("payload", payload)
                putExtra("snoozeLabel", snoozeLabel)
                putExtra("dismissLabel", dismissLabel)
                putExtra("doneLabel", doneLabel)
                putExtra("showDone", showDone)
                putExtra("soundResource", soundResource)
                putExtra("originalTime", originalTime)
                putExtra("dismissConfirm", dismissConfirm)
            }
            return PendingIntent.getBroadcast(
                context,
                id * 100 + offset,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val origLabel = getOriginalTimeLabel(snoozeLabel)
        val origText = if (!originalTime.isNullOrEmpty()) "$origLabel: $originalTime" else null

        val collapsedRemoteViews = RemoteViews(context.packageName, R.layout.notification_snooze_options).apply {
            setTextViewText(R.id.snoozeTitle, title)
            setTextViewText(R.id.snoozePrompt, promptText)
            if (origText != null) {
                setTextViewText(R.id.snoozeOriginalTime, origText)
                setViewVisibility(R.id.snoozeOriginalTime, android.view.View.VISIBLE)
            } else {
                setViewVisibility(R.id.snoozeOriginalTime, android.view.View.GONE)
            }
            setViewVisibility(R.id.snoozeOptionsContainer, android.view.View.GONE)
        }

        val expandedRemoteViews = RemoteViews(context.packageName, R.layout.notification_snooze_options).apply {
            setTextViewText(R.id.snoozeTitle, title)
            setTextViewText(R.id.snoozePrompt, promptText)
            if (origText != null) {
                setTextViewText(R.id.snoozeOriginalTime, origText)
                setViewVisibility(R.id.snoozeOriginalTime, android.view.View.VISIBLE)
            } else {
                setViewVisibility(R.id.snoozeOriginalTime, android.view.View.GONE)
            }
            setTextViewText(R.id.btnSnooze5, if (isTr) "5 dk" else "5m")
            setTextViewText(R.id.btnSnooze10, if (isTr) "10 dk" else "10m")
            setTextViewText(R.id.btnSnooze15, if (isTr) "15 dk" else "15m")
            setTextViewText(R.id.btnSnooze30, if (isTr) "30 dk" else "30m")
            setTextViewText(R.id.btnSnooze60, if (isTr) "60 dk" else "60m")

            setViewVisibility(R.id.snoozeOptionsContainer, android.view.View.VISIBLE)

            setOnClickPendingIntent(R.id.btnSnooze5, buildSnoozeChoicePendingIntent(5, 51))
            setOnClickPendingIntent(R.id.btnSnooze10, buildSnoozeChoicePendingIntent(10, 52))
            setOnClickPendingIntent(R.id.btnSnooze15, buildSnoozeChoicePendingIntent(15, 53))
            setOnClickPendingIntent(R.id.btnSnooze30, buildSnoozeChoicePendingIntent(30, 54))
            setOnClickPendingIntent(R.id.btnSnooze60, buildSnoozeChoicePendingIntent(60, 55))
        }

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(false)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(contentPendingIntent)
            .setDeleteIntent(deletePendingIntent)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(collapsedRemoteViews)
            .setCustomBigContentView(expandedRemoteViews)

        val notification = builder.build()
        notification.flags = notification.flags or 34 // FLAG_ONGOING_EVENT (2) or FLAG_NO_CLEAR (32)
        NotificationManagerCompat.from(context).notify(id, notification)
    }

    fun showDismissConfirmation(
        context: Context,
        id: Int,
        title: String,
        body: String,
        payload: String? = null,
        snoozeLabel: String = "Snooze",
        dismissLabel: String = "Dismiss",
        doneLabel: String = "Done",
        showDone: Boolean = false,
        soundResource: String? = "reminder_chime",
        originalTime: String? = null,
        dismissConfirm: Boolean = true
    ) {
        handledActions.remove(id)

        val contentIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("notification_id", id)
            putExtra("payload", payload)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("snoozeLabel", snoozeLabel)
            putExtra("dismissLabel", dismissLabel)
            putExtra("doneLabel", doneLabel)
            putExtra("showDone", showDone)
            putExtra("soundResource", soundResource)
            putExtra("originalTime", originalTime)
            putExtra("dismissConfirm", dismissConfirm)
        }
        val contentPendingIntent = PendingIntent.getActivity(
            context,
            id * 10,
            contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // If swiped away while showing confirmation, re-show original notification
        val dismissIntent = Intent(context, ReminderDismissReceiver::class.java).apply {
            action = ACTION_REMINDER_DISMISSED
            data = Uri.parse("reminder://dismiss/$id/${System.currentTimeMillis()}")
            putExtra("id", id)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("payload", payload)
            putExtra("snoozeLabel", snoozeLabel)
            putExtra("dismissLabel", dismissLabel)
            putExtra("doneLabel", doneLabel)
            putExtra("showDone", showDone)
            putExtra("soundResource", soundResource)
            putExtra("originalTime", originalTime)
            putExtra("dismissConfirm", dismissConfirm)
        }
        val deletePendingIntent = PendingIntent.getBroadcast(
            context,
            id * 10 + 9,
            dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val promptText = getDismissPrompt(snoozeLabel)
        val cancelText = getCancelLabel(snoozeLabel)

        fun buildDismissActionPendingIntent(actionId: String, offset: Int): PendingIntent {
            val intent = Intent(context, ReminderActionReceiver::class.java).apply {
                action = ReminderActionReceiver.ACTION_REMINDER_ACTION
                putExtra("actionId", actionId)
                putExtra("id", id)
                putExtra("title", title)
                putExtra("body", body)
                putExtra("payload", payload)
                putExtra("snoozeLabel", snoozeLabel)
                putExtra("dismissLabel", dismissLabel)
                putExtra("doneLabel", doneLabel)
                putExtra("showDone", showDone)
                putExtra("soundResource", soundResource)
                putExtra("originalTime", originalTime)
                putExtra("dismissConfirm", dismissConfirm)
            }
            return PendingIntent.getBroadcast(
                context,
                id * 100 + offset,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val confirmPendingIntent = buildDismissActionPendingIntent("action_dismiss_confirm", 71)
        val cancelPendingIntent = buildDismissActionPendingIntent("action_dismiss_cancel", 72)

        val origLabel = getOriginalTimeLabel(snoozeLabel)
        val origText = if (!originalTime.isNullOrEmpty()) "$origLabel: $originalTime" else null

        val collapsedRemoteViews = RemoteViews(context.packageName, R.layout.notification_dismiss_confirm).apply {
            setTextViewText(R.id.dismissConfirmTitle, title)
            setTextViewText(R.id.dismissConfirmPrompt, promptText)
            if (origText != null) {
                setTextViewText(R.id.dismissConfirmOriginalTime, origText)
                setViewVisibility(R.id.dismissConfirmOriginalTime, android.view.View.VISIBLE)
            } else {
                setViewVisibility(R.id.dismissConfirmOriginalTime, android.view.View.GONE)
            }
            setViewVisibility(R.id.dismissConfirmActionsContainer, android.view.View.GONE)
        }

        val expandedRemoteViews = RemoteViews(context.packageName, R.layout.notification_dismiss_confirm).apply {
            setTextViewText(R.id.dismissConfirmTitle, title)
            setTextViewText(R.id.dismissConfirmPrompt, promptText)
            if (origText != null) {
                setTextViewText(R.id.dismissConfirmOriginalTime, origText)
                setViewVisibility(R.id.dismissConfirmOriginalTime, android.view.View.VISIBLE)
            } else {
                setViewVisibility(R.id.dismissConfirmOriginalTime, android.view.View.GONE)
            }
            setTextViewText(R.id.btnDismissConfirm, dismissLabel)
            setTextViewText(R.id.btnDismissCancel, cancelText)

            setViewVisibility(R.id.dismissConfirmActionsContainer, android.view.View.VISIBLE)

            setOnClickPendingIntent(R.id.btnDismissConfirm, confirmPendingIntent)
            setOnClickPendingIntent(R.id.btnDismissCancel, cancelPendingIntent)
        }

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(false)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(contentPendingIntent)
            .setDeleteIntent(deletePendingIntent)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(collapsedRemoteViews)
            .setCustomBigContentView(expandedRemoteViews)

        val notification = builder.build()
        notification.flags = notification.flags or 34 // FLAG_ONGOING_EVENT (2) or FLAG_NO_CLEAR (32)
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
        showDone: Boolean = false,
        soundResource: String? = "reminder_chime",
        originalTime: String? = null,
        dismissConfirm: Boolean = true
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
            putExtra("showDone", showDone)
            putExtra("soundResource", soundResource)
            putExtra("originalTime", originalTime)
            putExtra("dismissConfirm", dismissConfirm)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id * 10 + 8,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
                } else {
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            }
        } catch (_: SecurityException) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            }
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
