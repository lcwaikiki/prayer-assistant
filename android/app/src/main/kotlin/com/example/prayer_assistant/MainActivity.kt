package com.pirci.prayer_assistant

import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var widgetChannel: MethodChannel
    private var pendingOpenHome: Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        widgetChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "prayer_assistant/widget"
        )
        widgetChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidgetData" -> {
                    val timeline = call.argument<List<Map<String, Any?>>>("timeline") ?: emptyList()
                    val todayPrayers = call.argument<List<Map<String, Any?>>>("todayPrayers") ?: emptyList()
                    val locationLabel = call.argument<String>("locationLabel") ?: ""
                    PrayerWidgetStorage.saveTimeline(this, timeline)
                    PrayerWidgetStorage.saveTodayPrayers(this, todayPrayers)
                    PrayerWidgetStorage.saveLocationLabel(this, locationLabel)
                    PrayerWidgetUpdater.updateAll(this)
                    PrayerWidgetUpdater.scheduleNextUpdate(this)
                    PrayerWidgetUpdater.scheduleIconRefresh(this)
                    PrayerWidgetUpdater.scheduleWidgetMinuteRefresh(this)
                    PrayerWidgetUpdater.scheduleWidgetSecondRefresh(this)
                    result.success(null)
                }
                "updateCalendarReminders" -> {
                    val headerText = call.argument<String>("headerText") ?: "Upcoming reminders"
                    val reminders = call.argument<List<Map<String, Any?>>>("reminders") ?: emptyList()
                    PrayerWidgetStorage.saveCalendarRemindersHeader(this, headerText)
                    PrayerWidgetStorage.saveCalendarReminders(this, reminders)
                    PrayerWidgetUpdater.updateAll(this)
                    result.success(null)
                }
                "updateWidgetTextSize" -> {
                    val size = call.argument<String>("size") ?: "medium"
                    PrayerWidgetStorage.saveWidgetTextSize(this, size)
                    PrayerWidgetUpdater.updateAll(this)
                    result.success(null)
                }
                "updateWidgetMmssThreshold" -> {
                    val minutes = call.argument<Int>("minutes") ?: 60
                    PrayerWidgetStorage.saveWidgetMmssThreshold(this, minutes)
                    PrayerWidgetUpdater.updateAll(this)
                    result.success(null)
                }
                "updateStatusBarConfig" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    PrayerWidgetStorage.saveStatusConfig(this, enabled, enabled)
                    PrayerWidgetUpdater.updateAll(this)
                    PrayerWidgetUpdater.scheduleNextUpdate(this)
                    PrayerWidgetUpdater.scheduleIconRefresh(this)
                    PrayerWidgetUpdater.scheduleWidgetMinuteRefresh(this)
                    PrayerWidgetUpdater.scheduleWidgetSecondRefresh(this)
                    result.success(null)
                }
                "consumePendingOpenHome" -> {
                    val shouldOpen = pendingOpenHome
                    pendingOpenHome = false
                    result.success(shouldOpen)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        maybeNotifyOpenHome(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        maybeNotifyOpenHome(intent)
    }

    private fun maybeNotifyOpenHome(intent: Intent?) {
        if (intent?.getBooleanExtra("open_home_tab", false) == true) {
            pendingOpenHome = true
        }
        if (!::widgetChannel.isInitialized) {
            return
        }
        if (pendingOpenHome) {
            pendingOpenHome = false
            widgetChannel.invokeMethod("openHomeTab", null)
        }
    }
}
