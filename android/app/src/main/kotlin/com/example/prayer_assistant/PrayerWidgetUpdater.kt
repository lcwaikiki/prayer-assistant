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
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.IconCompat
import android.app.Notification
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object PrayerWidgetUpdater {
    const val ACTION_REFRESH_WIDGETS = "com.example.prayer_assistant.ACTION_REFRESH_WIDGETS"
    const val ACTION_REFRESH_ICON = "com.example.prayer_assistant.ACTION_REFRESH_ICON"
    const val ACTION_REFRESH_WIDGET_MINUTE = "com.example.prayer_assistant.ACTION_REFRESH_WIDGET_MINUTE"
    const val ACTION_STATUS_DISMISSED = "com.example.prayer_assistant.ACTION_STATUS_DISMISSED"
    const val STATUS_CHANNEL_ID = "prayer_remaining_status"
    const val STATUS_NOTIFICATION_ID = 710001
    private const val ICON_DIGIT_THRESHOLD_MINUTES = 100L

    fun updateAll(context: Context) {
        val timeline = PrayerWidgetStorage.readTimeline(context)
        val now = System.currentTimeMillis()
        val next = timeline.firstOrNull { it.second > now } ?: timeline.firstOrNull()
        val textSize = PrayerWidgetStorage.readWidgetTextSize(context)
        val mmssThreshold = PrayerWidgetStorage.readWidgetMmssThreshold(context)

        val openPendingIntent = buildOpenPendingIntent(context)
        updateCountdownWidgets(context, next, now, textSize, mmssThreshold, openPendingIntent)

        val widgetManager = AppWidgetManager.getInstance(context)
        val dailyPrayerIds = widgetManager.getAppWidgetIds(
            ComponentName(context, DailyPrayerTimesWidgetProvider::class.java)
        )
        for (widgetId in dailyPrayerIds) {
            val views = buildDailyPrayerTimesView(context, next, openPendingIntent)
            widgetManager.updateAppWidget(widgetId, views)
        }

        val upcomingRemindersIds = widgetManager.getAppWidgetIds(
            ComponentName(context, UpcomingRemindersWidgetProvider::class.java)
        )
        for (widgetId in upcomingRemindersIds) {
            val views = buildUpcomingRemindersView(context, openPendingIntent)
            widgetManager.updateAppWidget(widgetId, views)
        }

        updateStatusBar(context, next)
    }

    /**
     * Re-renders only the three countdown widgets (Remaining Time, Circle,
     * Next Prayer). Called every second while under the MM:SS threshold, so it
     * must stay cheap: no daily/upcoming/status-bar work here.
     */
    fun updateCountdownWidgets(context: Context) {
        val timeline = PrayerWidgetStorage.readTimeline(context)
        val now = System.currentTimeMillis()
        val next = timeline.firstOrNull { it.second > now } ?: timeline.firstOrNull()
        val textSize = PrayerWidgetStorage.readWidgetTextSize(context)
        val mmssThreshold = PrayerWidgetStorage.readWidgetMmssThreshold(context)
        updateCountdownWidgets(
            context,
            next,
            now,
            textSize,
            mmssThreshold,
            buildOpenPendingIntent(context),
        )
    }

    private fun updateCountdownWidgets(
        context: Context,
        next: Pair<String, Long>?,
        now: Long,
        textSize: String,
        mmssThreshold: Int,
        openPendingIntent: PendingIntent,
    ) {
        val widgetManager = AppWidgetManager.getInstance(context)
        val nextPrayerName = next?.first ?: "--"

        val remainingIds = widgetManager.getAppWidgetIds(
            ComponentName(context, RemainingTimeWidgetProvider::class.java)
        )
        for (widgetId in remainingIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_remaining_time)
            views.setTextViewText(R.id.widgetRemainingOnlyLabel, nextPrayerName)
            setTextSizeSp(views, R.id.widgetRemainingOnlyLabel, textSize, 9f, 11f, 14f, 17f)
            setTextSizeSp(views, R.id.widgetRemainingOnlyValue, textSize, 16f, 22f, 30f, 34f)
            applyCountdown(views, R.id.widgetRemainingOnlyValue, next, now, mmssThreshold)
            views.setOnClickPendingIntent(R.id.widgetRemainingOnlyRoot, openPendingIntent)
            widgetManager.updateAppWidget(widgetId, views)
        }

        val circleIds = widgetManager.getAppWidgetIds(
            ComponentName(context, RemainingTimeCircleWidgetProvider::class.java)
        )
        for (widgetId in circleIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_remaining_time_circle)
            val diameterDp = circleDiameterDp(context, widgetId)
            setCircleTextSizeSp(views, context, textSize, diameterDp)
            applyCountdown(views, R.id.widgetRemainingCircleValue, next, now, mmssThreshold)
            views.setOnClickPendingIntent(R.id.widgetRemainingCircleRoot, openPendingIntent)
            applyCircleBackground(views, context, widgetId)
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
            applyCountdown(views, R.id.widgetNextPrayerRemaining, next, now, mmssThreshold)
            views.setOnClickPendingIntent(R.id.widgetNextPrayerRoot, openPendingIntent)
            widgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun buildOpenPendingIntent(context: Context): PendingIntent {
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("open_home_tab", true)
        }
        return PendingIntent.getActivity(
            context,
            2001,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    /**
     * Up to 3 fixed rows (title + pre-formatted, already-localized date/time from the Dart
     * side) rather than a RemoteViewsService-backed list — the reminder count shown here is
     * intentionally small, so a real scrolling list would be more machinery than the surface
     * warrants.
     */
    private fun buildUpcomingRemindersView(
        context: Context,
        openPendingIntent: PendingIntent
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_upcoming_reminders)
        views.setTextViewText(
            R.id.widgetUpcomingRemindersHeader,
            PrayerWidgetStorage.readCalendarRemindersHeader(context)
        )
        views.setOnClickPendingIntent(R.id.widgetUpcomingRemindersRoot, openPendingIntent)

        val reminders = PrayerWidgetStorage.readCalendarReminders(context)
        views.setViewVisibility(
            R.id.widgetUpcomingRemindersEmpty,
            if (reminders.isEmpty()) android.view.View.VISIBLE else android.view.View.GONE
        )

        val rowIds = intArrayOf(
            R.id.widgetUpcomingReminderRow1,
            R.id.widgetUpcomingReminderRow2,
            R.id.widgetUpcomingReminderRow3
        )
        val titleIds = intArrayOf(
            R.id.widgetUpcomingReminderTitle1,
            R.id.widgetUpcomingReminderTitle2,
            R.id.widgetUpcomingReminderTitle3
        )
        val whenIds = intArrayOf(
            R.id.widgetUpcomingReminderWhen1,
            R.id.widgetUpcomingReminderWhen2,
            R.id.widgetUpcomingReminderWhen3
        )
        for (i in rowIds.indices) {
            val reminder = reminders.getOrNull(i)
            if (reminder == null) {
                views.setViewVisibility(rowIds[i], android.view.View.GONE)
                continue
            }
            views.setViewVisibility(rowIds[i], android.view.View.VISIBLE)
            views.setTextViewText(titleIds[i], reminder.title)
            views.setTextViewText(whenIds[i], reminder.whenText)
        }
        return views
    }

    /**
     * Today's full prayer list as fixed rows (name + time), with the next
     * upcoming prayer highlighted. Reads the same already-localized today
     * snapshot the Dart side pushes for the status notification, so no extra
     * channel call is needed for this widget.
     */
    private fun buildDailyPrayerTimesView(
        context: Context,
        next: Pair<String, Long>?,
        openPendingIntent: PendingIntent
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_daily_prayer_times)
        views.setTextViewText(
            R.id.widgetDailyPrayersLocation,
            PrayerWidgetStorage.readLocationLabel(context)
        )
        views.setOnClickPendingIntent(R.id.widgetDailyPrayersRoot, openPendingIntent)

        val todayPrayers = PrayerWidgetStorage.readTodayPrayers(context)
        val rowIds = intArrayOf(
            R.id.widgetDailyRow1,
            R.id.widgetDailyRow2,
            R.id.widgetDailyRow3,
            R.id.widgetDailyRow4,
            R.id.widgetDailyRow5,
            R.id.widgetDailyRow6
        )
        val nameIds = intArrayOf(
            R.id.widgetDailyName1,
            R.id.widgetDailyName2,
            R.id.widgetDailyName3,
            R.id.widgetDailyName4,
            R.id.widgetDailyName5,
            R.id.widgetDailyName6
        )
        val timeIds = intArrayOf(
            R.id.widgetDailyTime1,
            R.id.widgetDailyTime2,
            R.id.widgetDailyTime3,
            R.id.widgetDailyTime4,
            R.id.widgetDailyTime5,
            R.id.widgetDailyTime6
        )

        for (i in rowIds.indices) {
            val prayer = todayPrayers.getOrNull(i)
            views.setTextViewText(nameIds[i], prayer?.first ?: "--")
            views.setTextViewText(timeIds[i], prayer?.let { formatClock(it.second) } ?: "--:--")
            val isNext = prayer != null && next != null && prayer.second == next.second
            if (isNext) {
                views.setInt(rowIds[i], "setBackgroundResource", R.drawable.widget_row_highlight)
            } else {
                views.setInt(rowIds[i], "setBackgroundColor", 0)
            }
        }
        return views
    }

    private fun circleDiameterDp(context: Context, widgetId: Int): Int {
        val options = AppWidgetManager.getInstance(context).getAppWidgetOptions(widgetId)
        val widthDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
        val heightDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
        return minOf(widthDp, heightDp).coerceAtLeast(40)
    }

    /**
     * The single countdown line must sit entirely inside the drawn circle, so its size is
     * derived from the circle's diameter rather than a fixed preference. The countdown can
     * render up to 5 glyphs ("M:SS" like "59:59") in live-countdown mode, so it's sized for
     * that worst case (~diameter/3 per glyph incl. spacing), scaled by the user's text-size
     * preference, and capped at the circle's pixel width.
     */
    private fun setCircleTextSizeSp(
        views: RemoteViews,
        context: Context,
        sizePreference: String,
        diameterDp: Int
    ) {
        val preferenceScale = when (sizePreference) {
            "extraSmall" -> 0.8f
            "small" -> 0.9f
            "large" -> 1.15f
            else -> 1.0f
        }
        val countdownSp = (diameterDp / 3.0f * preferenceScale).coerceIn(20f, 36f)
        views.setTextViewTextSize(
            R.id.widgetRemainingCircleValue,
            TypedValue.COMPLEX_UNIT_SP,
            countdownSp
        )
        val maxWidthPx = (diameterDp * context.resources.displayMetrics.density * 0.85f).toInt()
        views.setInt(R.id.widgetRemainingCircleValue, "setMaxWidth", maxWidthPx)
    }

    /**
     * Renders a true square circle (solid teal with a subtle white ring) as the widget's
     * image, sized to the smaller of the widget's reported cell dimensions so it never
     * stretches into an ellipse. A plain oval background drawable can't do this — shape
     * drawables always fill whatever bounds the host gives them.
     */
    private fun applyCircleBackground(views: RemoteViews, context: Context, widgetId: Int) {
        val density = context.resources.displayMetrics.density
        val diameter = (circleDiameterDp(context, widgetId) * density).toInt()

        val bitmap = Bitmap.createBitmap(diameter, diameter, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val radius = diameter / 2f
        canvas.drawCircle(radius, radius, radius, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#FF1F8A70")
        })
        canvas.drawCircle(
            radius,
            radius,
            radius - 2f * density,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.parseColor("#4DFFFFFF")
                style = Paint.Style.STROKE
                strokeWidth = 2f * density
            }
        )
        views.setImageViewBitmap(R.id.widgetRemainingCircleBg, bitmap)
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
     * Above [mmssThresholdMinutes] remaining, shows a static "HH:MM" string that we
     * refresh once a minute via [scheduleWidgetMinuteRefresh] (minutes-only precision
     * doesn't need finer-grained updates). Once under that threshold, switches to a
     * "M:SS" string with no leading zeros ("4:32", "9") refreshed once a second by
     * [CountdownTickService] via [updateCountdownWidgets]. A self-ticking platform
     * Chronometer can't render unpadded minutes (and custom views in widget layouts
     * break on several launchers), so the app drives these updates itself.
     */
    private fun applyCountdown(
        views: RemoteViews,
        viewId: Int,
        next: Pair<String, Long>?,
        now: Long,
        mmssThresholdMinutes: Int
    ) {
        if (next == null) {
            views.setTextViewText(viewId, "--:--")
            return
        }
        val remainingMs = next.second - now
        val remainingMinutes = remainingMs / 60_000L
        if (remainingMinutes >= mmssThresholdMinutes) {
            views.setTextViewText(viewId, formatHoursMinutes(remainingMs))
            return
        }
        views.setTextViewText(viewId, formatMinutesSeconds(remainingMs))
    }

    private fun formatHoursMinutes(remainingMs: Long): String {
        val totalMinutes = remainingMs / 60_000L
        val hours = totalMinutes / 60L
        val minutes = totalMinutes % 60L
        return if (hours > 0) "%d:%02d".format(hours, minutes) else "${minutes}"
    }

    private fun formatMinutesSeconds(remainingMs: Long): String {
        val totalSeconds = (remainingMs / 1000L).coerceAtLeast(0)
        val minutes = totalSeconds / 60L
        val seconds = totalSeconds % 60L
        return if (minutes > 0) {
            "$minutes:${seconds.toString().padStart(2, '0')}"
        } else {
            "$seconds"
        }
    }

    /**
     * Wakes the app only when the next prayer time actually passes (a handful of times a
     * day). Between wakeups the countdown text is kept fresh by the per-minute refresh
     * alarm ([scheduleWidgetMinuteRefresh]) and the per-second [CountdownTickService].
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
     * Keeps the widgets' "HH:MM" display (see [applyCountdown]) accurate to the minute while
     * above the configured MM:SS threshold remain. Once remaining time drops under that
     * threshold, [scheduleWidgetSecondRefresh] takes over and this alarm cancels itself
     * rather than continuing to fire.
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
        val mmssThreshold = PrayerWidgetStorage.readWidgetMmssThreshold(context).toLong()

        if (remainingMinutes == null || remainingMinutes < mmssThreshold) {
            alarmManager.cancel(pendingIntent)
            return
        }

        val triggerAt = ((now / 60_000L) + 1L) * 60_000L
        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
    }

    /**
     * Keeps [CountdownTickService] running while any countdown widget is under the
     * configured MM:SS threshold, so the widgets' "M:SS" countdown (see [applyCountdown])
     * ticks once a second without leading zeros ("4:32", "9"). Per-second exact alarms
     * were tried first, but the system throttles them to roughly 5-second spacing, so an
     * in-process service is the reliable way to hit one-second updates. Stops the service
     * once remaining time is back above the threshold or no countdown widget exists.
     */
    fun scheduleWidgetSecondRefresh(context: Context) {
        if (shouldTickPerSecond(context)) {
            ContextCompat.startForegroundService(
                context,
                Intent(context, CountdownTickService::class.java)
            )
        } else {
            context.stopService(Intent(context, CountdownTickService::class.java))
        }
    }

    /**
     * True while a countdown widget is installed, a next prayer exists, and its remaining
     * time is under the MM:SS threshold — i.e. when the per-second [CountdownTickService]
     * should be running.
     */
    fun shouldTickPerSecond(context: Context): Boolean {
        val now = System.currentTimeMillis()
        val next = nextPrayer(context) ?: return false
        val remainingMinutes = (next.second - now) / 60_000L
        return remainingMinutes < PrayerWidgetStorage.readWidgetMmssThreshold(context).toLong() &&
            hasCountdownWidgets(context)
    }

    fun nextPrayer(context: Context): Pair<String, Long>? =
        PrayerWidgetStorage.readTimeline(context)
            .firstOrNull { it.second > System.currentTimeMillis() }

    private fun hasCountdownWidgets(context: Context): Boolean {
        val manager = AppWidgetManager.getInstance(context)
        val providers = listOf(
            RemainingTimeWidgetProvider::class.java,
            NextPrayerWidgetProvider::class.java,
            RemainingTimeCircleWidgetProvider::class.java
        )
        return providers.any {
            manager.getAppWidgetIds(ComponentName(context, it)).isNotEmpty()
        }
    }

    internal fun updateStatusBar(context: Context, next: Pair<String, Long>?) {
        val manager = NotificationManagerCompat.from(context)
        if (!PrayerWidgetStorage.isStatusEnabled(context)) {
            manager.cancel(STATUS_NOTIFICATION_ID)
            return
        }
        createStatusChannel(context)
        manager.notify(STATUS_NOTIFICATION_ID, buildStatusNotification(context, next))
    }

    /**
     * Builds the status-bar countdown notification (live Chronometer views) when enabled,
     * or a minimal foreground-service notification otherwise. Used both by
     * [updateStatusBar] and by [CountdownTickService] as its foreground notification.
     */
    internal fun buildStatusNotification(
        context: Context,
        next: Pair<String, Long>?
    ): Notification {
        if (!PrayerWidgetStorage.isStatusEnabled(context)) {
            return NotificationCompat.Builder(context, STATUS_CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("Prayer Assistant")
                .setContentText("Widget countdown active")
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .setSilent(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .build()
        }
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
        return NotificationCompat.Builder(context, STATUS_CHANNEL_ID)
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
            .build()
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

    internal fun createStatusChannel(context: Context) {
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
