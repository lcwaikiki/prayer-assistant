package com.example.prayer_assistant

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.util.Locale
import kotlin.math.max

object PrayerWidgetUpdater {
    const val ACTION_REFRESH_WIDGETS = "com.example.prayer_assistant.ACTION_REFRESH_WIDGETS"
    const val ACTION_STATUS_DISMISSED = "com.example.prayer_assistant.ACTION_STATUS_DISMISSED"
    private const val STATUS_CHANNEL_ID = "prayer_remaining_status"
    private const val STATUS_NOTIFICATION_ID = 710001

    fun updateAll(context: Context) {
        val timeline = PrayerWidgetStorage.readTimeline(context)
        val now = System.currentTimeMillis()
        val next = timeline.firstOrNull { it.second > now } ?: timeline.firstOrNull()
        val remainingText = if (next == null) {
            "--:--"
        } else {
            formatRemaining(next.second - now)
        }
        val nextPrayerName = next?.first ?: "--"

        val widgetManager = AppWidgetManager.getInstance(context)
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("open_home_tab", true)
        }
        val openPendingIntent = PendingIntent.getActivity(
            context,
            2001,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val remainingIds = widgetManager.getAppWidgetIds(
            ComponentName(context, RemainingTimeWidgetProvider::class.java)
        )
        for (widgetId in remainingIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_remaining_time)
            views.setTextViewText(R.id.widgetRemainingOnlyValue, remainingText)
            views.setOnClickPendingIntent(R.id.widgetRemainingOnlyRoot, openPendingIntent)
            widgetManager.updateAppWidget(widgetId, views)
        }

        val nextIds = widgetManager.getAppWidgetIds(
            ComponentName(context, NextPrayerWidgetProvider::class.java)
        )
        for (widgetId in nextIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_next_prayer)
            views.setTextViewText(R.id.widgetNextPrayerName, nextPrayerName)
            views.setTextViewText(R.id.widgetNextPrayerRemaining, remainingText)
            views.setOnClickPendingIntent(R.id.widgetNextPrayerRoot, openPendingIntent)
            widgetManager.updateAppWidget(widgetId, views)
        }

        updateStatusBar(context, next, now)
    }

    fun scheduleNextUpdate(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val nextMinute = ((System.currentTimeMillis() / 60000L) + 1L) * 60000L
        val refreshIntent = Intent(context, PrayerWidgetTickReceiver::class.java).apply {
            action = ACTION_REFRESH_WIDGETS
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            2002,
            refreshIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            nextMinute,
            pendingIntent
        )
    }

    private fun formatRemaining(diffMillis: Long): String {
        val safeMillis = max(0L, diffMillis)
        val totalMinutes = safeMillis / 60000L
        val hours = totalMinutes / 60L
        val minutes = totalMinutes % 60L
        return String.format(Locale.US, "%02d:%02d", hours, minutes)
    }

    private fun updateStatusBar(
        context: Context,
        next: Pair<String, Long>?,
        now: Long
    ) {
        val manager = NotificationManagerCompat.from(context)
        if (!PrayerWidgetStorage.isStatusEnabled(context)) {
            manager.cancel(STATUS_NOTIFICATION_ID)
            return
        }
        createStatusChannel(context)
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("open_home_tab", true)
        }
        val openPendingIntent = PendingIntent.getActivity(
            context,
            2010,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val dismissIntent = Intent(context, StatusBarDismissReceiver::class.java).apply {
            action = ACTION_STATUS_DISMISSED
        }
        val dismissPendingIntent = PendingIntent.getBroadcast(
            context,
            2011,
            dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val remainingMinutes = if (next == null) {
            "--"
        } else {
            ((max(0L, next.second - now)) / 60000L).toString()
        }
        val builder = NotificationCompat.Builder(context, STATUS_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Remaining")
            .setContentText(remainingMinutes)
            .setStyle(NotificationCompat.BigTextStyle().bigText(remainingMinutes))
            .setContentIntent(openPendingIntent)
            .setDeleteIntent(dismissPendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
        manager.notify(STATUS_NOTIFICATION_ID, builder.build())
    }

    private fun createStatusChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        val channel = NotificationChannel(
            STATUS_CHANNEL_ID,
            "Prayer Remaining",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Remaining minutes in status bar"
            setShowBadge(false)
        }
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }
}
