package com.example.prayer_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class PrayerWidgetTickReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        PrayerWidgetUpdater.updateAll(context)
        PrayerWidgetUpdater.scheduleNextUpdate(context)
    }
}
