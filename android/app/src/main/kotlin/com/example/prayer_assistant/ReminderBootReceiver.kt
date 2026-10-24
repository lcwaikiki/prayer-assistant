package com.pirci.prayer_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ReminderBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return
        val action = intent.action ?: return
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON") {
            ReminderNotificationManager.rescheduleAll(context)
            PrayerSilentModeManager.rescheduleAll(context)
            PrayerWidgetUpdater.screenOnRefresh(context)
        }
    }
}
