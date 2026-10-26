package com.pirci.prayer_assistant

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.provider.Settings
import org.json.JSONObject

object PrayerSilentModeManager {
    const val ACTION_PRAYER_SILENT_START = "com.pirci.prayer_assistant.ACTION_PRAYER_SILENT_START"
    const val ACTION_PRAYER_SILENT_END = "com.pirci.prayer_assistant.ACTION_PRAYER_SILENT_END"

    private const val PREFS_NAME = "prayer_silent_mode_prefs"
    private const val KEY_PREVIOUS_RINGER_MODE = "previous_ringer_mode"
    private const val KEY_ACTIVE_SILENT_ID = "active_silent_id"
    private const val KEY_SILENT_END_TIME = "silent_end_time"
    private const val END_ALARM_REQUEST_CODE = 99942

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
        try {
            val json = JSONObject().apply {
                put("id", id)
                put("triggerAtMillis", triggerAtMillis)
                put("durationMinutes", durationMinutes)
            }
            getPrefs(context).edit().putString("silent_$id", json.toString()).apply()
        } catch (_: Throwable) {
        }
        val now = System.currentTimeMillis()
        if (triggerAtMillis <= now) {
            startSilentMode(context, id, durationMinutes)
        } else {
            setSilentAlarm(context, id, triggerAtMillis, durationMinutes)
        }
    }

    private fun setSilentAlarm(
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
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
                } else {
                    alarmManager.set(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
                }
            } catch (_: Throwable) {
            }
        } catch (_: Throwable) {
        }
    }

    fun cancelSilentMode(context: Context, id: Int) {
        try {
            getPrefs(context).edit().remove("silent_$id").apply()
        } catch (_: Throwable) {
        }
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
    }

    fun cancelAll(context: Context) {
        for (id in 1..100) {
            cancelSilentMode(context, id)
        }
    }

    fun checkAndDeactivateIfExpired(context: Context) {
        val prefs = getPrefs(context)
        if (prefs.contains(KEY_ACTIVE_SILENT_ID)) {
            val endTime = prefs.getLong(KEY_SILENT_END_TIME, 0L)
            if (endTime <= System.currentTimeMillis()) {
                endSilentMode(context)
            }
        }
    }

    fun rescheduleAll(context: Context) {
        val prefs = getPrefs(context)
        val now = System.currentTimeMillis()

        if (prefs.contains(KEY_ACTIVE_SILENT_ID)) {
            val endTime = prefs.getLong(KEY_SILENT_END_TIME, 0L)
            if (endTime <= now) {
                endSilentMode(context)
            } else {
                scheduleEndAlarm(context, endTime)
            }
        }

        val all = prefs.all
        val editor = prefs.edit()
        for ((key, value) in all) {
            if (!key.startsWith("silent_")) continue
            val jsonStr = value as? String ?: continue
            try {
                val json = JSONObject(jsonStr)
                val id = json.getInt("id")
                val triggerAtMillis = json.getLong("triggerAtMillis")
                val durationMinutes = json.getInt("durationMinutes")
                if (triggerAtMillis < now - 86400000L) {
                    editor.remove(key)
                    continue
                }
                if (triggerAtMillis >= now) {
                    setSilentAlarm(context, id, triggerAtMillis, durationMinutes)
                }
            } catch (_: Throwable) {
                editor.remove(key)
            }
        }
        editor.apply()
    }

    fun startSilentMode(context: Context, id: Int, durationMinutes: Int) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager ?: return
        val prefs = getPrefs(context)
        val endAtMillis = System.currentTimeMillis() + (durationMinutes * 60 * 1000L)

        if (!prefs.contains(KEY_ACTIVE_SILENT_ID)) {
            val currentMode = audioManager.ringerMode
            val modeToSave = if (currentMode == AudioManager.RINGER_MODE_NORMAL) {
                AudioManager.RINGER_MODE_NORMAL
            } else {
                prefs.getInt(KEY_PREVIOUS_RINGER_MODE, AudioManager.RINGER_MODE_NORMAL)
            }
            prefs.edit()
                .putInt(KEY_PREVIOUS_RINGER_MODE, modeToSave)
                .putInt(KEY_ACTIVE_SILENT_ID, id)
                .putLong(KEY_SILENT_END_TIME, endAtMillis)
                .apply()
        } else {
            prefs.edit()
                .putInt(KEY_ACTIVE_SILENT_ID, id)
                .putLong(KEY_SILENT_END_TIME, endAtMillis)
                .apply()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            if (nm != null && nm.isNotificationPolicyAccessGranted) {
                try {
                    nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_PRIORITY)
                } catch (_: Exception) {}
            }
        }

        try {
            audioManager.ringerMode = AudioManager.RINGER_MODE_VIBRATE
        } catch (_: Exception) {}

        scheduleEndAlarm(context, endAtMillis)
    }

    private fun scheduleEndAlarm(context: Context, endAtMillis: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, PrayerSilentModeReceiver::class.java).apply {
            action = ACTION_PRAYER_SILENT_END
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            END_ALARM_REQUEST_CODE,
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
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, endAtMillis, pendingIntent)
                } else {
                    alarmManager.set(AlarmManager.RTC_WAKEUP, endAtMillis, pendingIntent)
                }
            } catch (_: Throwable) {
            }
        } catch (_: Throwable) {
        }
    }

    fun endSilentMode(context: Context, id: Int = 0) {
        val prefs = getPrefs(context)
        val previousMode = prefs.getInt(KEY_PREVIOUS_RINGER_MODE, AudioManager.RINGER_MODE_NORMAL)
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
        val nm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        } else {
            null
        }

        // 1. Remove Do Not Disturb filter FIRST, so AudioManager allows changing ringerMode back to NORMAL
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && nm != null && nm.isNotificationPolicyAccessGranted) {
            try {
                nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
            } catch (_: Exception) {}
        }

        // 2. Restore ringer mode
        if (audioManager != null) {
            try {
                audioManager.ringerMode = previousMode
            } catch (_: Exception) {
                try {
                    audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
                } catch (_: Exception) {}
            }
        }

        // 3. Clear preferences
        prefs.edit()
            .remove(KEY_ACTIVE_SILENT_ID)
            .remove(KEY_PREVIOUS_RINGER_MODE)
            .remove(KEY_SILENT_END_TIME)
            .apply()

        // 4. Cancel any pending end alarm
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, PrayerSilentModeReceiver::class.java).apply {
            action = ACTION_PRAYER_SILENT_END
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            END_ALARM_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        if (pendingIntent != null) {
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
        }
    }
}
