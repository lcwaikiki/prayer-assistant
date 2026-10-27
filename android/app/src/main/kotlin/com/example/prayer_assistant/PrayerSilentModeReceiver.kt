package com.pirci.prayer_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager

class PrayerSilentModeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return
        android.util.Log.d("PrayerSilent", "PrayerSilentModeReceiver.onReceive action=${intent.action} id=${intent.getIntExtra("id", 0)}")
        val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
        val wakeLock = pm?.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "PrayerAssistant:SilentModeLock")
        try {
            wakeLock?.acquire(5000L)
        } catch (e: Exception) {
            android.util.Log.e("PrayerSilent", "Failed to acquire wakeLock", e)
        }

        try {
            val id = intent.getIntExtra("id", 0)
            when (intent.action) {
                PrayerSilentModeManager.ACTION_PRAYER_SILENT_START -> {
                    val durationMinutes = intent.getIntExtra("durationMinutes", 15)
                    android.util.Log.d("PrayerSilent", "START action received: id=$id, duration=$durationMinutes")
                    PrayerSilentModeManager.startSilentMode(context, id, durationMinutes)
                }
                PrayerSilentModeManager.ACTION_PRAYER_SILENT_END -> {
                    android.util.Log.d("PrayerSilent", "END action received: id=$id")
                    PrayerSilentModeManager.endSilentMode(context)
                }
            }
        } catch (e: Throwable) {
            android.util.Log.e("PrayerSilent", "Error in onReceive", e)
        } finally {
            try {
                if (wakeLock?.isHeld == true) {
                    wakeLock.release()
                }
            } catch (_: Exception) {}
        }
    }
}
