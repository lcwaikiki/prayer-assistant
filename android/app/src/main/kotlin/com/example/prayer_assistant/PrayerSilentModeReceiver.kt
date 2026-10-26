package com.pirci.prayer_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager

class PrayerSilentModeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return
        val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
        val wakeLock = pm?.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "PrayerAssistant:SilentModeLock")
        try {
            wakeLock?.acquire(3000L)
        } catch (_: Exception) {}

        try {
            val id = intent.getIntExtra("id", 0)
            when (intent.action) {
                PrayerSilentModeManager.ACTION_PRAYER_SILENT_START -> {
                    val durationMinutes = intent.getIntExtra("durationMinutes", 15)
                    PrayerSilentModeManager.startSilentMode(context, id, durationMinutes)
                }
                PrayerSilentModeManager.ACTION_PRAYER_SILENT_END -> {
                    PrayerSilentModeManager.endSilentMode(context)
                }
            }
        } finally {
            try {
                if (wakeLock?.isHeld == true) {
                    wakeLock.release()
                }
            } catch (_: Exception) {}
        }
    }
}
