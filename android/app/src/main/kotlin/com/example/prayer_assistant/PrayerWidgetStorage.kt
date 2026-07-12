package com.example.prayer_assistant

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object PrayerWidgetStorage {
    private const val PREFS_NAME = "PrayerWidgetPrefs"
    private const val TIMELINE_KEY = "timeline_json"
    private const val STATUS_ENABLED_KEY = "status_enabled"
    private const val STATUS_AUTO_RESTORE_KEY = "status_auto_restore"

    fun saveTimeline(context: Context, timeline: List<Map<String, Any?>>) {
        val json = JSONArray()
        for (entry in timeline) {
            val epoch = (entry["epochMs"] as? Number)?.toLong() ?: continue
            val name = entry["name"]?.toString() ?: continue
            json.put(
                JSONObject()
                    .put("epochMs", epoch)
                    .put("name", name)
            )
        }
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(TIMELINE_KEY, json.toString())
            .apply()
    }

    fun readTimeline(context: Context): List<Pair<String, Long>> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(TIMELINE_KEY, "[]") ?: "[]"
        val parsed = mutableListOf<Pair<String, Long>>()
        val json = JSONArray(raw)
        for (i in 0 until json.length()) {
            val item = json.optJSONObject(i) ?: continue
            val name = item.optString("name")
            val epoch = item.optLong("epochMs", -1L)
            if (name.isEmpty() || epoch <= 0L) {
                continue
            }
            parsed.add(name to epoch)
        }
        return parsed.sortedBy { it.second }
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
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(STATUS_AUTO_RESTORE_KEY, false)
    }
}
