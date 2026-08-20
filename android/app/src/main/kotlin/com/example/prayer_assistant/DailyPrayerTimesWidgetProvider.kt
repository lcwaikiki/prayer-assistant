package com.pirci.prayer_assistant

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context

class DailyPrayerTimesWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        PrayerWidgetUpdater.updateAll(context)
    }

    override fun onEnabled(context: Context) {
        PrayerWidgetUpdater.updateAll(context)
    }
}
