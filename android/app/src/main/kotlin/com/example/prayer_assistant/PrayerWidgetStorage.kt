package com.pirci.prayer_assistant

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/** A single upcoming calendar reminder, already formatted for display by the Dart side. */
data class CalendarReminderEntry(val title: String, val whenText: String, val epochMs: Long)

object PrayerWidgetStorage {
    private const val PREFS_NAME = "PrayerWidgetPrefs"
    private const val TIMELINE_KEY = "timeline_json"
    private const val TODAY_PRAYERS_KEY = "today_prayers_json"
    private const val LOCATION_LABEL_KEY = "location_label"
    private const val WIDGET_TEXT_SIZE_KEY = "widget_text_size"
    private const val WIDGET_THEME_KEY = "widget_theme"
    private const val APP_LOCALE_KEY = "app_locale"
    private const val WIDGET_MMSS_THRESHOLD_KEY = "widget_mmss_threshold_minutes"
    private const val STATUS_ENABLED_KEY = "status_enabled"
    private const val STATUS_AUTO_RESTORE_KEY = "status_auto_restore"
    private const val CALENDAR_REMINDERS_KEY = "calendar_reminders_json"
    private const val CALENDAR_REMINDERS_HEADER_KEY = "calendar_reminders_header"

    fun saveCalendarRemindersHeader(context: Context, headerText: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(CALENDAR_REMINDERS_HEADER_KEY, headerText)
            .apply()
    }

    fun readCalendarRemindersHeader(context: Context): String {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(CALENDAR_REMINDERS_HEADER_KEY, "Upcoming reminders") ?: "Upcoming reminders"
    }

    fun saveCalendarReminders(context: Context, reminders: List<Map<String, Any?>>) {
        val json = JSONArray()
        for (entry in reminders) {
            val title = entry["title"]?.toString() ?: continue
            val whenText = entry["when"]?.toString() ?: continue
            val epochMs = (entry["epochMs"] as? Number)?.toLong() ?: continue
            json.put(
                JSONObject()
                    .put("title", title)
                    .put("when", whenText)
                    .put("epochMs", epochMs)
            )
        }
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(CALENDAR_REMINDERS_KEY, json.toString())
            .apply()
    }

    fun readCalendarReminders(context: Context): List<CalendarReminderEntry> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(CALENDAR_REMINDERS_KEY, "[]") ?: "[]"
        val parsed = mutableListOf<CalendarReminderEntry>()
        val json = JSONArray(raw)
        for (i in 0 until json.length()) {
            val item = json.optJSONObject(i) ?: continue
            val title = item.optString("title")
            val whenText = item.optString("when")
            val epochMs = item.optLong("epochMs", -1L)
            if (title.isEmpty() || epochMs <= 0L) {
                continue
            }
            parsed.add(CalendarReminderEntry(title, whenText, epochMs))
        }
        return parsed.sortedBy { it.epochMs }
    }

    fun saveTimeline(context: Context, timeline: List<Map<String, Any?>>) {
        saveEntryList(context, TIMELINE_KEY, timeline)
    }

    fun readTimeline(context: Context): List<Pair<String, Long>> {
        return readEntryList(context, TIMELINE_KEY).sortedBy { it.second }
    }

    fun saveTodayPrayers(context: Context, prayers: List<Map<String, Any?>>) {
        saveEntryList(context, TODAY_PRAYERS_KEY, prayers)
    }

    fun readTodayPrayers(context: Context): List<Pair<String, Long>> {
        return readEntryList(context, TODAY_PRAYERS_KEY)
    }

    fun saveLocationLabel(context: Context, label: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(LOCATION_LABEL_KEY, label)
            .apply()
    }

    fun readLocationLabel(context: Context): String {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(LOCATION_LABEL_KEY, "") ?: ""
    }

    fun saveWidgetTextSize(context: Context, size: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(WIDGET_TEXT_SIZE_KEY, size)
            .apply()
    }

    fun readWidgetTextSize(context: Context): String {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(WIDGET_TEXT_SIZE_KEY, "medium") ?: "medium"
    }

    fun saveWidgetTheme(context: Context, theme: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(WIDGET_THEME_KEY, theme)
            .apply()
    }

    fun readWidgetTheme(context: Context): String {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(WIDGET_THEME_KEY, "system") ?: "system"
    }

    private const val WIDGET_CALENDAR_DISPLAY_KEY = "widget_calendar_display"
    private const val DATE_HEADER_HIJRI_KEY = "date_header_hijri"
    private const val DATE_HEADER_GREGORIAN_KEY = "date_header_gregorian"

    fun saveWidgetCalendarDisplay(context: Context, display: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(WIDGET_CALENDAR_DISPLAY_KEY, display)
            .apply()
    }

    fun readWidgetCalendarDisplay(context: Context): String {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(WIDGET_CALENDAR_DISPLAY_KEY, "both") ?: "both"
    }

    fun saveDateHeaders(context: Context, hijri: String, gregorian: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(DATE_HEADER_HIJRI_KEY, hijri)
            .putString(DATE_HEADER_GREGORIAN_KEY, gregorian)
            .apply()
    }

    fun readDateHeaderHijri(context: Context): String {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(DATE_HEADER_HIJRI_KEY, "") ?: ""
    }

    fun readDateHeaderGregorian(context: Context): String {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(DATE_HEADER_GREGORIAN_KEY, "") ?: ""
    }

    fun saveAppLocale(context: Context, locale: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(APP_LOCALE_KEY, locale)
            .apply()
    }

    fun readAppLocale(context: Context): String {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(APP_LOCALE_KEY, "") ?: ""
    }

    /**
     * Minutes below which widgets switch to a live MM:SS countdown instead of
     * the minute-granularity HH:MM format (0-60, default 60).
     */
    fun saveWidgetMmssThreshold(context: Context, minutes: Int) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putInt(WIDGET_MMSS_THRESHOLD_KEY, minutes.coerceIn(0, 60))
            .apply()
    }

    fun readWidgetMmssThreshold(context: Context): Int {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getInt(WIDGET_MMSS_THRESHOLD_KEY, 60)
            .coerceIn(0, 60)
    }

    private fun saveEntryList(context: Context, key: String, entries: List<Map<String, Any?>>) {
        val json = JSONArray()
        for (entry in entries) {
            val epoch = (entry["epochMs"] as? Number)?.toLong() ?: continue
            val name = entry["name"]?.toString() ?: continue
            val rawName = entry["rawName"]?.toString() ?: name
            json.put(
                JSONObject()
                    .put("epochMs", epoch)
                    .put("name", name)
                    .put("rawName", rawName)
            )
        }
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(key, json.toString())
            .apply()
    }

    data class PrayerEntry(val name: String, val rawName: String, val epochMs: Long)

    fun readTodayPrayersDetailed(context: Context): List<PrayerEntry> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(TODAY_PRAYERS_KEY, "[]") ?: "[]"
        val parsed = mutableListOf<PrayerEntry>()
        val json = JSONArray(raw)
        for (i in 0 until json.length()) {
            val item = json.optJSONObject(i) ?: continue
            val name = item.optString("name")
            val rawName = item.optString("rawName", name)
            val epoch = item.optLong("epochMs", -1L)
            if (name.isEmpty() || epoch <= 0L) {
                continue
            }
            parsed.add(PrayerEntry(name, rawName, epoch))
        }
        return parsed
    }

    private fun readEntryList(context: Context, key: String): List<Pair<String, Long>> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(key, "[]") ?: "[]"
        val parsed = mutableListOf<Pair<String, Long>>()
        val json = JSONArray(raw)
        for (i in 0 until json.length()) {
            val item = json.optJSONObject(i) ?: continue
            val name = item.optString("name")
            val rawName = item.optString("rawName", name)
            val epoch = item.optLong("epochMs", -1L)
            if (name.isEmpty() || epoch <= 0L) {
                continue
            }
            parsed.add((if (name.isNotEmpty()) name else rawName) to epoch)
        }
        return parsed
    }


    fun saveStatusConfig(
        context: Context,
        enabled: Boolean,
        autoRestore: Boolean
    ) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(STATUS_ENABLED_KEY, enabled)
            .putBoolean(STATUS_AUTO_RESTORE_KEY, autoRestore)
            .apply()
    }

    fun isStatusEnabled(context: Context): Boolean {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(STATUS_ENABLED_KEY, true)
    }

    fun isStatusAutoRestore(context: Context): Boolean {
        return isStatusEnabled(context)
    }
}
