package com.pirci.prayer_assistant

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.os.Bundle

/** Widget provider that redraws its widgets whenever the user resizes one. */
abstract class ResizableWidgetProvider : AppWidgetProvider() {
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        PrayerWidgetUpdater.updateAll(context)
    }
}
