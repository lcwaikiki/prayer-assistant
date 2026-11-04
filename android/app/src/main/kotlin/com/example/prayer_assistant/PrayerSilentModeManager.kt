package com.pirci.prayer_assistant

import android.app.Activity
import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
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
    private const val KEY_PREVIOUS_RING_VOLUME = "previous_ring_volume"
    private const val KEY_PREVIOUS_NOTIF_VOLUME = "previous_notif_volume"
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

    fun requestStartSilentMode(context: Context, id: Int, durationMinutes: Int) {
        if (context is Activity || context is Service) {
            startSilentMode(context, id, durationMinutes)
            return
        }
        val serviceIntent = Intent(context, PrayerSilentModeService::class.java).apply {
            action = ACTION_PRAYER_SILENT_START
            putExtra("id", id)
            putExtra("durationMinutes", durationMinutes)
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        } catch (e: Exception) {
            android.util.Log.w("PrayerSilent", "Failed to start PrayerSilentModeService, falling back to startSilentMode", e)
            startSilentMode(context, id, durationMinutes)
        }
    }

    fun requestEndSilentMode(context: Context) {
        if (context is Activity || context is Service) {
            endSilentMode(context)
            return
        }
        val serviceIntent = Intent(context, PrayerSilentModeService::class.java).apply {
            action = ACTION_PRAYER_SILENT_END
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        } catch (e: Exception) {
            android.util.Log.w("PrayerSilent", "Failed to start PrayerSilentModeService, falling back to endSilentMode", e)
            endSilentMode(context)
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
            requestStartSilentMode(context, id, durationMinutes)
        } else {
            setSilentAlarm(context, id, triggerAtMillis, durationMinutes)
        }
    }

    private fun setExactAlarmSafely(
        alarmManager: AlarmManager,
        triggerAtMillis: Long,
        pendingIntent: PendingIntent
    ) {
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
            } catch (_: Throwable) {}
        } catch (_: Throwable) {}
    }

    private fun setSilentAlarm(
        context: Context,
        id: Int,
        triggerAtMillis: Long,
        durationMinutes: Int
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceIntent = Intent(context, PrayerSilentModeService::class.java).apply {
                action = ACTION_PRAYER_SILENT_START
                putExtra("id", id)
                putExtra("durationMinutes", durationMinutes)
            }
            PendingIntent.getForegroundService(
                context,
                id * 100 + 41,
                serviceIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } else {
            val broadcastIntent = Intent(context, PrayerSilentModeReceiver::class.java).apply {
                action = ACTION_PRAYER_SILENT_START
                setPackage(context.packageName)
                putExtra("id", id)
                putExtra("durationMinutes", durationMinutes)
            }
            PendingIntent.getBroadcast(
                context,
                id * 100 + 41,
                broadcastIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val showIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val showPendingIntent = PendingIntent.getActivity(
            context,
            id * 100 + 40,
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            val clockInfo = AlarmManager.AlarmClockInfo(triggerAtMillis, showPendingIntent)
            alarmManager.setAlarmClock(clockInfo, pendingIntent)
        } catch (_: Throwable) {
            setExactAlarmSafely(alarmManager, triggerAtMillis, pendingIntent)
        }
    }

    fun cancelSilentMode(context: Context, id: Int) {
        try {
            getPrefs(context).edit().remove("silent_$id").apply()
        } catch (_: Throwable) {}

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceIntent = Intent(context, PrayerSilentModeService::class.java).apply {
                action = ACTION_PRAYER_SILENT_START
            }
            val servicePending = PendingIntent.getForegroundService(
                context,
                id * 100 + 41,
                serviceIntent,
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            )
            if (servicePending != null) {
                alarmManager.cancel(servicePending)
                servicePending.cancel()
            }
        }

        val startIntent = Intent(context, PrayerSilentModeReceiver::class.java).apply {
            action = ACTION_PRAYER_SILENT_START
            setPackage(context.packageName)
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

    fun cancelAll(context: Context, cancelActive: Boolean = true) {
        for (id in 1..100) {
            cancelSilentMode(context, id)
        }
        if (cancelActive) {
            val prefs = getPrefs(context)
            if (prefs.contains(KEY_ACTIVE_SILENT_ID)) {
                requestEndSilentMode(context)
            }
        }
    }

    fun checkAndDeactivateIfExpired(context: Context) {
        val prefs = getPrefs(context)
        if (prefs.contains(KEY_ACTIVE_SILENT_ID)) {
            val endTime = prefs.getLong(KEY_SILENT_END_TIME, 0L)
            if (endTime <= System.currentTimeMillis()) {
                requestEndSilentMode(context)
            }
        }
    }

    fun rescheduleAll(context: Context) {
        val prefs = getPrefs(context)
        val now = System.currentTimeMillis()

        if (prefs.contains(KEY_ACTIVE_SILENT_ID)) {
            val endTime = prefs.getLong(KEY_SILENT_END_TIME, 0L)
            if (endTime <= now) {
                requestEndSilentMode(context)
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
        if (!hasDndPermission(context)) {
            android.util.Log.w("PrayerSilent", "startSilentMode aborted: DND permission not granted")
            return
        }
        val prefs = getPrefs(context)
        val now = System.currentTimeMillis()
        val calculatedEndAtMillis = now + (durationMinutes * 60 * 1000L)

        val endAtMillis = if (prefs.contains(KEY_ACTIVE_SILENT_ID)) {
            val existingEndTime = prefs.getLong(KEY_SILENT_END_TIME, 0L)
            if (existingEndTime > now) existingEndTime else calculatedEndAtMillis
        } else {
            val currentRingVol = audioManager.getStreamVolume(AudioManager.STREAM_RING)
            val currentNotifVol = audioManager.getStreamVolume(AudioManager.STREAM_NOTIFICATION)

            prefs.edit()
                .putInt(KEY_PREVIOUS_RINGER_MODE, AudioManager.RINGER_MODE_NORMAL)
                .putInt(KEY_PREVIOUS_RING_VOLUME, if (currentRingVol > 0) currentRingVol else prefs.getInt(KEY_PREVIOUS_RING_VOLUME, -1))
                .putInt(KEY_PREVIOUS_NOTIF_VOLUME, if (currentNotifVol > 0) currentNotifVol else prefs.getInt(KEY_PREVIOUS_NOTIF_VOLUME, -1))
                .apply()
            calculatedEndAtMillis
        }

        prefs.edit()
            .putInt(KEY_ACTIVE_SILENT_ID, id)
            .putLong(KEY_SILENT_END_TIME, endAtMillis)
            .apply()

        try {
            audioManager.ringerMode = AudioManager.RINGER_MODE_VIBRATE
            android.util.Log.d("PrayerSilent", "startSilentMode: set ringerMode to VIBRATE, newMode=${audioManager.ringerMode}")
        } catch (e: Exception) {
            android.util.Log.e("PrayerSilent", "startSilentMode: failed to set ringerMode to VIBRATE", e)
        }

        scheduleEndAlarm(context, endAtMillis)
        android.util.Log.d("PrayerSilent", "startSilentMode: scheduled end alarm at $endAtMillis (in ${durationMinutes}m)")
    }

    private fun scheduleEndAlarm(context: Context, endAtMillis: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceIntent = Intent(context, PrayerSilentModeService::class.java).apply {
                action = ACTION_PRAYER_SILENT_END
            }
            PendingIntent.getForegroundService(
                context,
                END_ALARM_REQUEST_CODE,
                serviceIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } else {
            val broadcastIntent = Intent(context, PrayerSilentModeReceiver::class.java).apply {
                action = ACTION_PRAYER_SILENT_END
                setPackage(context.packageName)
            }
            PendingIntent.getBroadcast(
                context,
                END_ALARM_REQUEST_CODE,
                broadcastIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val showIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val showPendingIntent = PendingIntent.getActivity(
            context,
            END_ALARM_REQUEST_CODE + 1,
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            val clockInfo = AlarmManager.AlarmClockInfo(endAtMillis, showPendingIntent)
            alarmManager.setAlarmClock(clockInfo, pendingIntent)
        } catch (_: Throwable) {
            setExactAlarmSafely(alarmManager, endAtMillis, pendingIntent)
        }
    }

    fun endSilentMode(context: Context, id: Int = 0) {
        val prefs = getPrefs(context)
        val previousRingVol = prefs.getInt(KEY_PREVIOUS_RING_VOLUME, -1)
        val previousNotifVol = prefs.getInt(KEY_PREVIOUS_NOTIF_VOLUME, -1)

        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
        val nm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        } else {
            null
        }

        // 1. Ensure Do Not Disturb is NOT blocking the ringer if policy access is granted
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && nm != null && nm.isNotificationPolicyAccessGranted) {
            try {
                if (nm.currentInterruptionFilter != NotificationManager.INTERRUPTION_FILTER_ALL) {
                    nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
                }
            } catch (e: Exception) {
                android.util.Log.e("PrayerSilent", "endSilentMode: failed to set interruption filter", e)
            }
        }

        // 2. Cancel any scheduled end alarm
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceIntent = Intent(context, PrayerSilentModeService::class.java).apply {
                action = ACTION_PRAYER_SILENT_END
            }
            val servicePending = PendingIntent.getForegroundService(
                context,
                END_ALARM_REQUEST_CODE,
                serviceIntent,
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            )
            if (servicePending != null) {
                alarmManager.cancel(servicePending)
                servicePending.cancel()
            }
        }
        val intent = Intent(context, PrayerSilentModeReceiver::class.java).apply {
            action = ACTION_PRAYER_SILENT_END
            setPackage(context.packageName)
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

        // 3. Restore ringer mode and stream volumes synchronously
        var restorationSucceeded = false
        if (audioManager != null) {
            val flags = AudioManager.FLAG_ALLOW_RINGER_MODES

            // A. Set ringer mode to NORMAL first
            try {
                audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
                android.util.Log.d("PrayerSilent", "endSilentMode: ringerMode set to NORMAL, mode=${audioManager.ringerMode}")
            } catch (e: Exception) {
                android.util.Log.e("PrayerSilent", "endSilentMode: failed to set ringerMode to NORMAL", e)
            }

            // B. Unmute and restore STREAM_RING volume
            val maxRing = audioManager.getStreamMaxVolume(AudioManager.STREAM_RING)
            val targetRing = if (previousRingVol > 0) previousRingVol else (maxRing * 2 / 3).coerceAtLeast(1)

            try {
                audioManager.adjustStreamVolume(AudioManager.STREAM_RING, AudioManager.ADJUST_UNMUTE, flags)
            } catch (e: Exception) {
                android.util.Log.e("PrayerSilent", "endSilentMode: failed to unmute STREAM_RING", e)
            }

            try {
                audioManager.setStreamVolume(AudioManager.STREAM_RING, targetRing, flags)
                android.util.Log.d("PrayerSilent", "endSilentMode: restored STREAM_RING to $targetRing")
            } catch (e: Exception) {
                android.util.Log.e("PrayerSilent", "endSilentMode: failed to set STREAM_RING", e)
            }

            // C. Restore and unmute STREAM_NOTIFICATION
            try {
                val maxNotif = audioManager.getStreamMaxVolume(AudioManager.STREAM_NOTIFICATION)
                val targetNotif = if (previousNotifVol > 0) previousNotifVol else (maxNotif * 2 / 3).coerceAtLeast(1)
                audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_UNMUTE, flags)
                audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, targetNotif, flags)
                android.util.Log.d("PrayerSilent", "endSilentMode: restored STREAM_NOTIFICATION to $targetNotif")
            } catch (e: Exception) {
                android.util.Log.e("PrayerSilent", "endSilentMode: failed to set STREAM_NOTIFICATION", e)
            }

            // D. Restore STREAM_SYSTEM volume
            try {
                val maxSys = audioManager.getStreamMaxVolume(AudioManager.STREAM_SYSTEM)
                val targetSys = (maxSys * 2 / 3).coerceAtLeast(1)
                audioManager.setStreamVolume(AudioManager.STREAM_SYSTEM, targetSys, flags)
            } catch (_: Exception) {}

            // E. Ensure ringerMode is indeed NORMAL (retry if reverted by volume state)
            try {
                if (audioManager.ringerMode != AudioManager.RINGER_MODE_NORMAL) {
                    audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
                    audioManager.setStreamVolume(AudioManager.STREAM_RING, targetRing, flags)
                }
            } catch (_: Exception) {}

            restorationSucceeded = (audioManager.ringerMode == AudioManager.RINGER_MODE_NORMAL)
            android.util.Log.d("PrayerSilent", "endSilentMode completed: currentMode=${audioManager.ringerMode}, ringVol=${audioManager.getStreamVolume(AudioManager.STREAM_RING)}, success=$restorationSucceeded")
        }

        // 4. Clear preferences if restoration succeeded, or if expired over 2 hours ago
        val now = System.currentTimeMillis()
        val endTime = prefs.getLong(KEY_SILENT_END_TIME, 0L)
        if (restorationSucceeded || (endTime > 0 && now > endTime + 7200000L)) {
            prefs.edit()
                .remove(KEY_ACTIVE_SILENT_ID)
                .remove(KEY_PREVIOUS_RINGER_MODE)
                .remove(KEY_PREVIOUS_RING_VOLUME)
                .remove(KEY_PREVIOUS_NOTIF_VOLUME)
                .remove(KEY_SILENT_END_TIME)
                .apply()
        }
    }
}
