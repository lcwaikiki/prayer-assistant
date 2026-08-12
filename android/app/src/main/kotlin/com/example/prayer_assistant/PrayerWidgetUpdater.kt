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
import android.os.SystemClock
import android.util.TypedValue
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object PrayerWidgetUpdater {
    const val ACTION_REFRESH_WIDGETS = "com.example.prayer_assistant.ACTION_REFRESH_WIDGETS"
    const val ACTION_STATUS_DISMISSED = "com.example.prayer_assistant.ACTION_STATUS_DISMISSED"
    private const val STATUS_CHANNEL_ID = "prayer_remaining_status"
    private const val STATUS_NOTIFICATION_ID = 710001

    fun updateAll(context: Context) {
        val timeline = PrayerWidgetStorage.readTimeline(context)
        val now = System.currentTimeMillis()
        val next = timeline.firstOrNull { it.second > now } ?: timeline.firstOrNull()
        val nextPrayerName = next?.first ?: "--"
        val countdownBase = next?.let { SystemClock.elapsedRealtime() + (it.second - now) }
        val textSize = PrayerWidgetStorage.readWidgetTextSize(context)

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
            views.setTextViewText(
                R.id.widgetRemainingOnlyLabel,
                PrayerWidgetStorage.readRemainingLabel(context)
            )
            setTextSizeSp(views, R.id.widgetRemainingOnlyLabel, textSize, 9f, 11f, 14f, 17f)
            setTextSizeSp(views, R.id.widgetRemainingOnlyValue, textSize, 16f, 22f, 30f, 34f)
            applyCountdown(views, R.id.widgetRemainingOnlyValue, countdownBase)
            views.setOnClickPendingIntent(R.id.widgetRemainingOnlyRoot, openPendingIntent)
            widgetManager.updateAppWidget(widgetId, views)
        }

        val nextIds = widgetManager.getAppWidgetIds(
            ComponentName(context, NextPrayerWidgetProvider::class.java)
        )
        for (widgetId in nextIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_next_prayer)
            setTextSizeSp(views, R.id.widgetNextPrayerName, textSize, 10f, 12f, 16f, 20f)
            setTextSizeSp(views, R.id.widgetNextPrayerRemaining, textSize, 15f, 20f, 28f, 32f)
            views.setTextViewText(R.id.widgetNextPrayerName, nextPrayerName)
            applyCountdown(views, R.id.widgetNextPrayerRemaining, countdownBase)
            views.setOnClickPendingIntent(R.id.widgetNextPrayerRoot, openPendingIntent)
            widgetManager.updateAppWidget(widgetId, views)
        }

        updateStatusBar(context, next)
    }

    private fun setTextSizeSp(
        views: RemoteViews,
        viewId: Int,
        sizePreference: String,
        extraSmall: Float,
        small: Float,
        medium: Float,
        large: Float
    ) {
        val sp = when (sizePreference) {
            "extraSmall" -> extraSmall
            "small" -> small
            "large" -> large
            else -> medium
        }
        views.setTextViewTextSize(viewId, TypedValue.COMPLEX_UNIT_SP, sp)
    }

    /**
     * Renders a live, self-ticking countdown via the platform Chronometer view so the
     * displayed value stays accurate between our (now rare) wakeups, instead of a static
     * string that only ever reflects the last time we happened to redraw it.
     */
    private fun applyCountdown(views: RemoteViews, viewId: Int, base: Long?) {
        if (base == null) {
            views.setChronometer(viewId, SystemClock.elapsedRealtime(), null, false)
            views.setTextViewText(viewId, "--:--")
            return
        }
        views.setChronometer(viewId, base, null, true)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            views.setChronometerCountDown(viewId, true)
        }
    }

    /**
     * Wakes the app only when the next prayer time actually passes (a handful of times a
     * day), instead of on a fixed polling interval forever. Between wakeups the Chronometer
     * views tick on their own without any alarm at all.
     */
    fun scheduleNextUpdate(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val refreshIntent = Intent(context, PrayerWidgetTickReceiver::class.java).apply {
            action = ACTION_REFRESH_WIDGETS
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            2002,
            refreshIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val now = System.currentTimeMillis()
        val nextTransition = PrayerWidgetStorage.readTimeline(context)
            .firstOrNull { it.second > now }
            ?.second

        if (nextTransition == null) {
            alarmManager.cancel(pendingIntent)
            return
        }

        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            nextTransition + 1_000L,
            pendingIntent
        )
    }

    private fun updateStatusBar(context: Context, next: Pair<String, Long>?) {
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
        val contentView = buildStatusContentView(context, next)
        val expandedView = buildStatusExpandedView(context, next)
        val builder = NotificationCompat.Builder(context, STATUS_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Prayer Assistant")
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(contentView)
            .setCustomBigContentView(expandedView)
            .setContentIntent(openPendingIntent)
            .setDeleteIntent(dismissPendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
        manager.notify(STATUS_NOTIFICATION_ID, builder.build())
    }

    /**
     * Builds "<prayer> at <time> -> <live ticking countdown>" as a single row, with the
     * countdown rendered by a real Chronometer view so it ticks every second without any
     * app wakeups. The standard NotificationCompat template has no way to splice a live
     * value into arbitrary text, so this uses a small custom RemoteViews layout instead.
     */
    private fun buildStatusContentView(context: Context, next: Pair<String, Long>?): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.notification_status_bar)
        if (next == null) {
            views.setTextViewText(R.id.statusPrayerLabel, "--")
            views.setChronometer(R.id.statusCountdown, SystemClock.elapsedRealtime(), null, false)
            views.setTextViewText(R.id.statusCountdown, "--:--")
            return views
        }
        views.setTextViewText(
            R.id.statusPrayerLabel,
            "${toDisplayPrayerName(next.first)} at ${formatClock(next.second)} ->"
        )
        val base = SystemClock.elapsedRealtime() + (next.second - System.currentTimeMillis())
        views.setChronometer(R.id.statusCountdown, base, null, true)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            views.setChronometerCountDown(R.id.statusCountdown, true)
        }
        return views
    }

    /**
     * Builds the expanded notification view: all of today's prayers in a row, with the
     * current/next one highlighted, plus a live countdown and the location label below.
     * Reuses the same today-prayers snapshot the Dart side already pushes on every refresh,
     * so this costs nothing extra to keep in sync with the collapsed view.
     */
    private fun buildStatusExpandedView(context: Context, next: Pair<String, Long>?): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.notification_status_bar_expanded)
        val todayPrayers = PrayerWidgetStorage.readTodayPrayers(context)
        val columnIds = intArrayOf(
            R.id.columnImsak,
            R.id.columnGunes,
            R.id.columnOgle,
            R.id.columnIkindi,
            R.id.columnAksam,
            R.id.columnYatsi
        )
        val nameIds = intArrayOf(
            R.id.nameImsak,
            R.id.nameGunes,
            R.id.nameOgle,
            R.id.nameIkindi,
            R.id.nameAksam,
            R.id.nameYatsi
        )
        val timeIds = intArrayOf(
            R.id.timeImsak,
            R.id.timeGunes,
            R.id.timeOgle,
            R.id.timeIkindi,
            R.id.timeAksam,
            R.id.timeYatsi
        )

        for (i in columnIds.indices) {
            val prayer = todayPrayers.getOrNull(i)
            views.setTextViewText(nameIds[i], prayer?.first ?: "--")
            views.setTextViewText(timeIds[i], prayer?.let { formatClock(it.second) } ?: "--:--")
            val isNext = prayer != null && next != null && prayer.second == next.second
            if (isNext) {
                views.setInt(columnIds[i], "setBackgroundResource", R.drawable.notification_pill_bg)
            } else {
                views.setInt(columnIds[i], "setBackgroundColor", 0)
            }
        }

        if (next == null) {
            views.setChronometer(R.id.expandedCountdown, SystemClock.elapsedRealtime(), null, false)
            views.setTextViewText(R.id.expandedCountdown, "--:--")
        } else {
            val base = SystemClock.elapsedRealtime() + (next.second - System.currentTimeMillis())
            views.setChronometer(R.id.expandedCountdown, base, null, true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                views.setChronometerCountDown(R.id.expandedCountdown, true)
            }
        }

        views.setTextViewText(
            R.id.expandedLocationLabel,
            PrayerWidgetStorage.readLocationLabel(context)
        )
        return views
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

    private fun formatClock(epochMs: Long): String {
        val formatter = SimpleDateFormat("HH:mm", Locale.getDefault())
        return formatter.format(Date(epochMs))
    }

    private fun toDisplayPrayerName(raw: String): String = raw
}
