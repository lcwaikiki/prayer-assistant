package com.pirci.prayer_assistant

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class PrayerSilentModeService : Service() {
    companion object {
        private const val CHANNEL_ID = "prayer_silent_service_channel"
        private const val NOTIFICATION_ID = 99941
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        val id = intent?.getIntExtra("id", 0) ?: 0
        val durationMinutes = intent?.getIntExtra("durationMinutes", 15) ?: 15
        android.util.Log.d("PrayerSilent", "PrayerSilentModeService.onStartCommand action=$action id=$id")

        createNotificationChannel()

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Prayer Silent Mode")
            .setContentText("Updating sound settings...")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    startForeground(
                        NOTIFICATION_ID,
                        notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                    )
                } else {
                    startForeground(NOTIFICATION_ID, notification)
                }
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } catch (e: Throwable) {
            android.util.Log.e("PrayerSilent", "Failed to startForeground in PrayerSilentModeService", e)
        }

        try {
            when (action) {
                PrayerSilentModeManager.ACTION_PRAYER_SILENT_START -> {
                    PrayerSilentModeManager.startSilentMode(this, id, durationMinutes)
                }
                PrayerSilentModeManager.ACTION_PRAYER_SILENT_END -> {
                    PrayerSilentModeManager.endSilentMode(this, id)
                }
                else -> {
                    PrayerSilentModeManager.checkAndDeactivateIfExpired(this)
                }
            }
        } catch (e: Throwable) {
            android.util.Log.e("PrayerSilent", "Error in PrayerSilentModeService execution", e)
        } finally {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    stopForeground(STOP_FOREGROUND_REMOVE)
                } else {
                    @Suppress("DEPRECATION")
                    stopForeground(true)
                }
            } catch (_: Throwable) {}
            stopSelf(startId)
        }

        return START_NOT_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            if (nm != null && nm.getNotificationChannel(CHANNEL_ID) == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Prayer Silent Service",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Temporary service to toggle prayer silent mode"
                    setShowBadge(false)
                }
                nm.createNotificationChannel(channel)
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}

