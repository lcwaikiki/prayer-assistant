package com.pirci.prayer_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class StatusBarDismissReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (!PrayerWidgetStorage.isStatusAutoRestore(context)) {
            return
        }
        PrayerWidgetUpdater.updateAll(context)
        PrayerWidgetUpdater.scheduleNextUpdate(context)
        PrayerWidgetUpdater.scheduleIconRefresh(context)
        PrayerWidgetUpdater.scheduleWidgetMinuteRefresh(context)
    }
}
