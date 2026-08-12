package com.example.prayer_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class PrayerWidgetTickReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == PrayerWidgetUpdater.ACTION_REFRESH_ICON) {
            PrayerWidgetUpdater.updateAll(context)
            PrayerWidgetUpdater.scheduleIconRefresh(context)
            return
        }
        PrayerWidgetUpdater.updateAll(context)
        PrayerWidgetUpdater.scheduleNextUpdate(context)
        PrayerWidgetUpdater.scheduleIconRefresh(context)
    }
}
