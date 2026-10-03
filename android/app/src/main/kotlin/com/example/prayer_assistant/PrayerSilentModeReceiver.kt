package com.pirci.prayer_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class PrayerSilentModeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return
        val id = intent.getIntExtra("id", 0)
        when (intent.action) {
            PrayerSilentModeManager.ACTION_PRAYER_SILENT_START -> {
                val durationMinutes = intent.getIntExtra("durationMinutes", 15)
                PrayerSilentModeManager.startSilentMode(context, id, durationMinutes)
            }
            PrayerSilentModeManager.ACTION_PRAYER_SILENT_END -> {
                PrayerSilentModeManager.endSilentMode(context, id)
            }
        }
    }
}
