package com.pirci.prayer_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

import android.os.Handler
import android.os.Looper

class StatusBarDismissReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (!PrayerWidgetStorage.isStatusAutoRestore(context)) {
            return
        }
        val pendingResult = goAsync()
        Handler(Looper.getMainLooper()).postDelayed({
            try {
                PrayerWidgetUpdater.updateAll(context)
                PrayerWidgetUpdater.scheduleNextUpdate(context)
                PrayerWidgetUpdater.scheduleIconRefresh(context)
                PrayerWidgetUpdater.scheduleWidgetMinuteRefresh(context)
            } finally {
                pendingResult.finish()
            }
        }, 150L)
    }
}
