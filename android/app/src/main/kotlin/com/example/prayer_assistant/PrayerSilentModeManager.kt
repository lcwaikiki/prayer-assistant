package com.pirci.prayer_assistant

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.provider.Settings

object PrayerSilentModeManager {
    const val ACTION_PRAYER_SILENT_START = "com.pirci.prayer_assistant.ACTION_PRAYER_SILENT_START"
    const val ACTION_PRAYER_SILENT_END = "com.pirci.prayer_assistant.ACTION_PRAYER_SILENT_END"

    private const val PREFS_NAME = "prayer_silent_mode_prefs"
    private const val KEY_PREVIOUS_RINGER_MODE = "previous_ringer_mode"
    private const val KEY_ACTIVE_SILENT_ID = "active_silent_id"

    private fun getPrefs(context: Context) =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun hasDndPermission(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            nm?.isNotificationPolicyAccessGranted == true
        } else {
            true
        }
    }

    fun openDndSettings(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            try {
                context.startActivity(intent)
            } catch (_: Exception) {}
        }
    }

    fun scheduleSilentMode(
        context: Context,
        id: Int,
        triggerAtMillis: Long,
        durationMinutes: Int
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, PrayerSilentModeReceiver::class.java).apply {
            action = ACTION_PRAYER_SILENT_START
            putExtra("id", id)
            putExtra("durationMinutes", durationMinutes)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id * 100 + 41,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
                } else {
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            }
        } catch (_: SecurityException) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            }
        }
    }

    fun cancelSilentMode(context: Context, id: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val startIntent = Intent(context, PrayerSilentModeReceiver::class.java).apply {
            action = ACTION_PRAYER_SILENT_START
        }
        val startPending = PendingIntent.getBroadcast(
            context,
            id * 100 + 41,
            startIntent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        if (startPending != null) {
            alarmManager.cancel(startPending)
            startPending.cancel()
        }

        val endIntent = Intent(context, PrayerSilentModeReceiver::class.java).apply {
            action = ACTION_PRAYER_SILENT_END
        }
        val endPending = PendingIntent.getBroadcast(
            context,
            id * 100 + 42,
            endIntent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        if (endPending != null) {
            alarmManager.cancel(endPending)
            endPending.cancel()
        }
    }

    fun cancelAll(context: Context) {
        for (id in 1..48) {
            cancelSilentMode(context, id)
        }
    }

    fun startSilentMode(context: Context, id: Int, durationMinutes: Int) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager ?: return
        val prefs = getPrefs(context)

        if (!prefs.contains(KEY_ACTIVE_SILENT_ID)) {
            val currentMode = audioManager.ringerMode
            prefs.edit()
                .putInt(KEY_PREVIOUS_RINGER_MODE, currentMode)
                .putInt(KEY_ACTIVE_SILENT_ID, id)
                .apply()
        } else {
            prefs.edit().putInt(KEY_ACTIVE_SILENT_ID, id).apply()
        }

        try {
            audioManager.ringerMode = AudioManager.RINGER_MODE_VIBRATE
        } catch (_: Exception) {}

        val endAtMillis = System.currentTimeMillis() + (durationMinutes * 60 * 1000L)
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, PrayerSilentModeReceiver::class.java).apply {
            action = ACTION_PRAYER_SILENT_END
            putExtra("id", id)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id * 100 + 42,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, endAtMillis, pendingIntent)
                } else {
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, endAtMillis, pendingIntent)
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, endAtMillis, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, endAtMillis, pendingIntent)
            }
        } catch (_: SecurityException) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, endAtMillis, pendingIntent)
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, endAtMillis, pendingIntent)
            }
        }
    }

    fun endSilentMode(context: Context, id: Int) {
        val prefs = getPrefs(context)
        val activeId = prefs.getInt(KEY_ACTIVE_SILENT_ID, -1)
        if (activeId == id || activeId == -1) {
            val previousMode = prefs.getInt(KEY_PREVIOUS_RINGER_MODE, AudioManager.RINGER_MODE_NORMAL)
            val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
            if (audioManager != null) {
                if (audioManager.ringerMode == AudioManager.RINGER_MODE_VIBRATE) {
                    try {
                        audioManager.ringerMode = previousMode
                    } catch (_: Exception) {}
                }
            }
            prefs.edit().remove(KEY_ACTIVE_SILENT_ID).remove(KEY_PREVIOUS_RINGER_MODE).apply()
        }
    }
}
