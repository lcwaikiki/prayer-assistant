package com.example.prayer_assistant

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.os.Build
import android.os.SystemClock
import android.util.TypedValue
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.graphics.drawable.IconCompat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object PrayerWidgetUpdater {
    const val ACTION_REFRESH_WIDGETS = "com.example.prayer_assistant.ACTION_REFRESH_WIDGETS"
    const val ACTION_REFRESH_ICON = "com.example.prayer_assistant.ACTION_REFRESH_ICON"
    const val ACTION_REFRESH_WIDGET_MINUTE = "com.example.prayer_assistant.ACTION_REFRESH_WIDGET_MINUTE"
    const val ACTION_STATUS_DISMISSED = "com.example.prayer_assistant.ACTION_STATUS_DISMISSED"
    private const val STATUS_CHANNEL_ID = "prayer_remaining_status"
    private const val STATUS_NOTIFICATION_ID = 710001
    private const val ICON_DIGIT_THRESHOLD_MINUTES = 100L
    private const val WIDGET_HHMM_THRESHOLD_MINUTES = 60L

    fun updateAll(context: Context) {
        val timeline = PrayerWidgetStorage.readTimeline(context)
        val now = System.currentTimeMillis()
        val next = timeline.firstOrNull { it.second > now } ?: timeline.firstOrNull()
        val nextPrayerName = next?.first ?: "--"
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
            views.setTextViewText(R.id.widgetRemainingOnlyLabel, nextPrayerName)
            setTextSizeSp(views, R.id.widgetRemainingOnlyLabel, textSize, 9f, 11f, 14f, 17f)
            setTextSizeSp(views, R.id.widgetRemainingOnlyValue, textSize, 16f, 22f, 30f, 34f)
            applyCountdown(views, R.id.widgetRemainingOnlyValue, next, now)
            views.setOnClickPendingIntent(R.id.widgetRemainingOnlyRoot, openPendingIntent)
            widgetManager.updateAppWidget(widgetId, views)
        }

        val nextIds = widgetManager.getAppWidgetIds(
            ComponentName(context, NextPrayerWidgetProvider::class.java)
        )
        for (widgetId in nextIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_next_prayer)
            setTextSizeSp(views, R.id.widgetNextPrayerName, textSize, 10f, 12f, 16f, 20f)
            setTextSizeSp(views, R.id.widgetNextPrayerTime, textSize, 10f, 12f, 16f, 20f)
            setTextSizeSp(views, R.id.widgetNextPrayerRemaining, textSize, 15f, 20f, 28f, 32f)
            views.setTextViewText(R.id.widgetNextPrayerName, nextPrayerName)
            views.setTextViewText(
                R.id.widgetNextPrayerTime,
                next?.let { formatClock(it.second) } ?: "--:--"
            )
            applyCountdown(views, R.id.widgetNextPrayerRemaining, next, now)
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
     * Above [WIDGET_HHMM_THRESHOLD_MINUTES] remaining, shows a static "HH.MM" string that we
     * refresh once a minute via [scheduleWidgetMinuteRefresh] (minutes-only precision doesn't
     * need finer-grained updates). Once under that threshold, switches to a live, self-ticking
     * "MM:SS" countdown via the platform Chronometer view, which ticks every second in the
     * widget host process with no further wakeups from us at all.
     */
    private fun applyCountdown(views: RemoteViews, viewId: Int, next: Pair<String, Long>?, now: Long) {
        if (next == null) {
            views.setChronometer(viewId, SystemClock.elapsedRealtime(), null, false)
            views.setTextViewText(viewId, "--:--")
            return
        }
        val remainingMs = next.second - now
        val remainingMinutes = remainingMs / 60_000L
        if (remainingMinutes >= WIDGET_HHMM_THRESHOLD_MINUTES) {
            views.setChronometer(viewId, SystemClock.elapsedRealtime(), null, false)
            views.setTextViewText(viewId, formatHoursMinutes(remainingMs))
            return
        }
        val base = SystemClock.elapsedRealtime() + remainingMs
        views.setChronometer(viewId, base, null, true)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            views.setChronometerCountDown(viewId, true)
        }
    }

    private fun formatHoursMinutes(remainingMs: Long): String {
        val totalMinutes = remainingMs / 60_000L
        val hours = totalMinutes / 60L
        val minutes = totalMinutes % 60L
        return "%02d.%02d".format(hours, minutes)
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

    /**
     * Keeps the status-bar minutes-remaining icon (see [buildSmallIcon]) accurate to the
     * minute. Unlike the Chronometer-based text, a notification's small icon is a static
     * bitmap with no live-ticking equivalent, so it genuinely needs a wakeup per minute to
     * stay current. An inexact wakeup was tried first, but Doze batching measurably delayed
     * it by several minutes once the device sat idle, so this uses an exact wakeup instead.
     * The cost is bounded, not unconditional: it only runs while under
     * [ICON_DIGIT_THRESHOLD_MINUTES] remain (jumping straight to that threshold instead of
     * ticking through the hours beforehand), and it's cancelled outright when the status
     * notification is disabled.
     */
    fun scheduleIconRefresh(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val iconIntent = Intent(context, PrayerWidgetTickReceiver::class.java).apply {
            action = ACTION_REFRESH_ICON
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            2003,
            iconIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val now = System.currentTimeMillis()
        val next = PrayerWidgetStorage.readTimeline(context).firstOrNull { it.second > now }

        if (next == null || !PrayerWidgetStorage.isStatusEnabled(context)) {
            alarmManager.cancel(pendingIntent)
            return
        }

        val remainingMinutes = (next.second - now) / 60_000L
        val triggerAt = if (remainingMinutes >= ICON_DIGIT_THRESHOLD_MINUTES) {
            next.second - (ICON_DIGIT_THRESHOLD_MINUTES - 1L) * 60_000L
        } else {
            ((now / 60_000L) + 1L) * 60_000L
        }

        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
    }

    /**
     * Keeps the widgets' "HH.MM" display (see [applyCountdown]) accurate to the minute while
     * above [WIDGET_HHMM_THRESHOLD_MINUTES] remain. Once remaining time drops under that
     * threshold, the Chronometer views take over ticking every second on their own, so this
     * alarm cancels itself rather than continuing to fire.
     */
    fun scheduleWidgetMinuteRefresh(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val minuteIntent = Intent(context, PrayerWidgetTickReceiver::class.java).apply {
            action = ACTION_REFRESH_WIDGET_MINUTE
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            2004,
            minuteIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val now = System.currentTimeMillis()
        val next = PrayerWidgetStorage.readTimeline(context).firstOrNull { it.second > now }
        val remainingMinutes = next?.let { (it.second - now) / 60_000L }

        if (remainingMinutes == null || remainingMinutes < WIDGET_HHMM_THRESHOLD_MINUTES) {
            alarmManager.cancel(pendingIntent)
            return
        }

        val triggerAt = ((now / 60_000L) + 1L) * 60_000L
        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
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
            .setSmallIcon(buildSmallIcon(context, next))
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
     * Status bar icon: under [ICON_DIGIT_THRESHOLD_MINUTES] minutes remaining, shows the
     * minute count itself (drawn as a white silhouette bitmap, the required style for
     * notification small icons); otherwise falls back to the app icon, since a 3-digit
     * number doesn't read well at status-bar-icon size.
     */
    private fun buildSmallIcon(context: Context, next: Pair<String, Long>?): IconCompat {
        val remainingMinutes = next?.let { (it.second - System.currentTimeMillis()) / 60_000L }
        if (remainingMinutes == null || remainingMinutes >= ICON_DIGIT_THRESHOLD_MINUTES) {
            return IconCompat.createWithResource(context, R.mipmap.ic_launcher)
        }
        val sizePx = (48 * context.resources.displayMetrics.density).toInt().coerceAtLeast(48)
        val bitmap = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val text = remainingMinutes.coerceIn(0L, 99L).toString().padStart(2, '0')
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textAlign = Paint.Align.CENTER
            // Condensed face: narrower glyphs mean more of the width budget goes to
            // point size instead of character width, for a visibly larger digit.
            typeface = Typeface.create("sans-serif-condensed", Typeface.BOLD)
        }
        // Fit to the text's actual ink bounds (not font ascent/descent, which reserve
        // slack for descenders digits don't have) on whichever axis is tighter, so the
        // glyphs fill almost the entire square canvas in both directions.
        val referenceSize = sizePx.toFloat()
        paint.textSize = referenceSize
        val bounds = android.graphics.Rect()
        paint.getTextBounds(text, 0, text.length, bounds)
        val available = sizePx * 0.99f
        val scale = minOf(available / bounds.width(), available / bounds.height())
        paint.textSize = referenceSize * scale
        paint.getTextBounds(text, 0, text.length, bounds)
        val xPos = sizePx / 2f
        val yPos = sizePx / 2f - bounds.exactCenterY()
        canvas.drawText(text, xPos, yPos, paint)
        return IconCompat.createWithBitmap(bitmap)
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
