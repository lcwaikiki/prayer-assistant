package com.pirci.prayer_assistant

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import java.text.NumberFormat

/**
 * Today's qadaa progress against the daily goal, total remaining, and a
 * "+1 full day" button. Taps on the button are queued in
 * [QadaaWidgetStorage] and merged by the app on its next start or resume.
 */
class QadaaWidgetProvider : ResizableWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        updateWidgets(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_ADD_DAY) {
            QadaaWidgetStorage.addPendingDay(context, QadaaWidgetStorage.todayKey())
            updateWidgets(context)
        }
    }

    companion object {
        private const val ACTION_ADD_DAY = "com.pirci.prayer_assistant.ACTION_QADAA_ADD_DAY"
        private const val ADD_DAY_REQUEST_CODE = 2101

        fun updateWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, QadaaWidgetProvider::class.java))
            if (ids.isEmpty()) return
            val views = buildView(context)
            for (id in ids) {
                manager.updateAppWidget(id, views)
            }
        }

        private fun buildView(context: Context): RemoteViews {
            val state = QadaaWidgetStorage.readState(context)
            val pending = QadaaWidgetStorage.readPending(context)
            val todayKey = QadaaWidgetStorage.todayKey()
            val perDay = QadaaWidgetStorage.PRAYERS_PER_DAY
            val loggedToday = if (state.dateKey == todayKey) state.todayCount else 0
            val today = loggedToday + (pending[todayKey] ?: 0) * perDay
            val remaining = (state.remaining - pending.values.sum() * perDay).coerceAtLeast(0)
            val progress = if (state.goal > 0) (today * 100 / state.goal).coerceAtMost(100) else 0

            val views = RemoteViews(context.packageName, R.layout.widget_qadaa)
            val textSize = PrayerWidgetStorage.readWidgetTextSize(context)
            val primary = PrayerWidgetUpdater.getPrimaryTextColor(context)
            val secondary = PrayerWidgetUpdater.getSecondaryTextColor(context)

            views.setInt(R.id.widgetQadaaRoot, "setBackgroundResource", PrayerWidgetUpdater.getWidgetBgRes(context))
            views.setTextColor(R.id.widgetQadaaTitle, primary)
            views.setTextColor(R.id.widgetQadaaGoal, secondary)
            views.setTextColor(R.id.widgetQadaaRemaining, secondary)
            views.setTextColor(R.id.widgetQadaaAddDay, primary)
            PrayerWidgetUpdater.setTextSizeSp(views, R.id.widgetQadaaTitle, textSize, 11f, 13f, 15f, 18f)
            PrayerWidgetUpdater.setTextSizeSp(views, R.id.widgetQadaaToday, textSize, 28f, 34f, 40f, 46f)
            PrayerWidgetUpdater.setTextSizeSp(views, R.id.widgetQadaaRemaining, textSize, 9f, 11f, 13f, 15f)

            views.setTextViewText(R.id.widgetQadaaTitle, state.title)
            views.setTextViewText(R.id.widgetQadaaToday, "$today")
            views.setTextViewText(R.id.widgetQadaaGoal, "/ ${state.goal}")
            views.setProgressBar(R.id.widgetQadaaProgress, 100, progress, false)
            views.setTextViewText(
                R.id.widgetQadaaRemaining,
                "${NumberFormat.getIntegerInstance().format(remaining)}\n${state.remainingLabel}",
            )
            views.setTextViewText(R.id.widgetQadaaAddDay, state.addDayLabel)

            views.setOnClickPendingIntent(
                R.id.widgetQadaaRoot,
                PrayerWidgetUpdater.buildOpenPendingIntent(context, PrayerWidgetUpdater.TARGET_QADAA),
            )
            views.setOnClickPendingIntent(R.id.widgetQadaaAddDay, addDayPendingIntent(context))
            return views
        }

        private fun addDayPendingIntent(context: Context): PendingIntent {
            val intent = Intent(context, QadaaWidgetProvider::class.java).setAction(ACTION_ADD_DAY)
            return PendingIntent.getBroadcast(
                context,
                ADD_DAY_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }
}
