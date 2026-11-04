package com.pirci.prayer_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager

class PrayerSilentModeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        val id = intent.getIntExtra("id", 0)
        android.util.Log.d("PrayerSilent", "PrayerSilentModeReceiver.onReceive action=$action id=$id")

        val pendingResult = goAsync()
        val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
        val wakeLock = pm?.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "PrayerAssistant:SilentModeLock")
        try {
            wakeLock?.acquire(10000L)
        } catch (e: Exception) {
            android.util.Log.e("PrayerSilent", "Failed to acquire wakeLock", e)
        }

        try {
            when (action) {
                PrayerSilentModeManager.ACTION_PRAYER_SILENT_START -> {
                    val durationMinutes = intent.getIntExtra("durationMinutes", 15)
                    android.util.Log.d("PrayerSilent", "START action received: id=$id, duration=$durationMinutes")
                    PrayerSilentModeManager.requestStartSilentMode(context, id, durationMinutes)
                }
                PrayerSilentModeManager.ACTION_PRAYER_SILENT_END -> {
                    android.util.Log.d("PrayerSilent", "END action received: id=$id")
                    PrayerSilentModeManager.requestEndSilentMode(context)
                }
                Intent.ACTION_TIME_CHANGED, Intent.ACTION_TIMEZONE_CHANGED -> {
                    android.util.Log.d("PrayerSilent", "Time changed, checking silent mode status")
                    PrayerSilentModeManager.checkAndDeactivateIfExpired(context)
                    PrayerSilentModeManager.rescheduleAll(context)
                }
                Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> {
                    android.util.Log.d("PrayerSilent", "Boot/replace received, rescheduling silent mode")
                    PrayerSilentModeManager.rescheduleAll(context)
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
            try {
                pendingResult.finish()
            } catch (_: Exception) {}
        }
    }
}
