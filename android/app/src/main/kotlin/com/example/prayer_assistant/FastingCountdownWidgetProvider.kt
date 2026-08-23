package com.pirci.prayer_assistant

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context

class FastingCountdownWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        PrayerWidgetUpdater.updateAll(context)
        PrayerWidgetUpdater.scheduleNextUpdate(context)
        PrayerWidgetUpdater.scheduleWidgetMinuteRefresh(context)
        PrayerWidgetUpdater.scheduleWidgetSecondRefresh(context)
    }

    override fun onEnabled(context: Context) {
        PrayerWidgetUpdater.updateAll(context)
        PrayerWidgetUpdater.scheduleNextUpdate(context)
        PrayerWidgetUpdater.scheduleWidgetMinuteRefresh(context)
        PrayerWidgetUpdater.scheduleWidgetSecondRefresh(context)
    }

    override fun onDisabled(context: Context) {
        PrayerWidgetUpdater.scheduleWidgetSecondRefresh(context)
    }
}
