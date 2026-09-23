package com.pirci.prayer_assistant

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper

/**
 * Foreground service that drives the widgets' "M:SS" countdown once a second from an
 * in-process Handler. Per-second exact alarms are throttled by the system to roughly
 * 5-second spacing, and launcher hosts can also delay background widget updates, so the
 * app keeps itself alive here while any countdown widget is under the MM:SS threshold.
 * The minute-level and prayer-transition alarms continue to run alongside; this service
 * only re-renders the countdown widgets (cheap) and is stopped by
 * [PrayerWidgetUpdater.scheduleWidgetSecondRefresh] when no longer needed.
 *
 * While alive it also holds a context-registered SCREEN_ON/USER_PRESENT receiver
 * (manifest receivers for these implicit broadcasts no longer fire on Android 8+),
 * so widgets and the status-bar icon re-render the moment the screen turns on.
 */
class CountdownTickService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var screenReceiverRegistered = false
    private val tickRunnable = object : Runnable {
        override fun run() {
            PrayerWidgetUpdater.updateCountdownWidgets(this@CountdownTickService)
            handler.postDelayed(this, 1_000L)
        }
    }

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent?) {
            PrayerWidgetUpdater.screenOnRefresh(context)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!PrayerWidgetUpdater.shouldTickPerSecond(this)) {
            stopSelf()
            return START_NOT_STICKY
        }
        PrayerWidgetUpdater.createStatusChannel(this)
        startForeground(
            PrayerWidgetUpdater.STATUS_NOTIFICATION_ID,
            PrayerWidgetUpdater.buildStatusNotification(this, PrayerWidgetUpdater.nextPrayer(this))
        )
        val screenFilter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        if (!screenReceiverRegistered) {
            registerReceiver(screenReceiver, screenFilter)
            screenReceiverRegistered = true
        }
        handler.removeCallbacks(tickRunnable)
        handler.postDelayed(tickRunnable, 1_000L)
        return START_STICKY
    }

    override fun onDestroy() {
        if (screenReceiverRegistered) {
            unregisterReceiver(screenReceiver)
            screenReceiverRegistered = false
        }
        handler.removeCallbacks(tickRunnable)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        PrayerWidgetUpdater.updateStatusBar(this, PrayerWidgetUpdater.nextPrayer(this))
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}