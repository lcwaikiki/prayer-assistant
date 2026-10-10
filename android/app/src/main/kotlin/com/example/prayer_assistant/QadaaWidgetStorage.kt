package com.pirci.prayer_assistant

import android.content.Context
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** Qadaa progress as last pushed by the app, with labels already localized. */
data class QadaaWidgetState(
    val dateKey: String,
    val todayCount: Int,
    val goal: Int,
    val remaining: Int,
    val title: String,
    val remainingLabel: String,
    val addDayLabel: String,
)

/**
 * Qadaa widget data. The app pushes its state here; "+1 full day" taps from
 * the widget are queued as pending days (dateKey -> count) until the app
 * merges them into its daily log, so the widget never writes the app's
 * database directly.
 */
object QadaaWidgetStorage {
    private const val PREFS_NAME = "QadaaWidgetPrefs"
    private const val STATE_KEY = "state_json"
    private const val PENDING_KEY = "pending_json"
    const val PRAYERS_PER_DAY = 6

    fun todayKey(): String = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())

    fun saveState(context: Context, state: Map<String, Any?>) {
        prefs(context).edit().putString(STATE_KEY, JSONObject(state).toString()).apply()
    }

    fun readState(context: Context): QadaaWidgetState {
        val json = JSONObject(prefs(context).getString(STATE_KEY, "{}") ?: "{}")
        return QadaaWidgetState(
            dateKey = json.optString("dateKey"),
            todayCount = json.optInt("todayCount"),
            goal = json.optInt("goal", PRAYERS_PER_DAY),
            remaining = json.optInt("remaining"),
            title = json.optString("title", "Prayer Qadaa"),
            remainingLabel = json.optString("remainingLabel", "Total Remaining"),
            addDayLabel = json.optString("addDayLabel", "+1 Full Day"),
        )
    }

    fun addPendingDay(context: Context, dateKey: String) {
        val pending = readPending(context)
        pending[dateKey] = (pending[dateKey] ?: 0) + 1
        prefs(context).edit().putString(PENDING_KEY, JSONObject(pending.toMap()).toString()).apply()
    }

    fun readPending(context: Context): MutableMap<String, Int> {
        val json = JSONObject(prefs(context).getString(PENDING_KEY, "{}") ?: "{}")
        return json.keys().asSequence().associateWith { json.getInt(it) }.toMutableMap()
    }

    /** Returns the queued days and clears the queue. */
    fun consumePending(context: Context): Map<String, Int> {
        val pending = readPending(context)
        prefs(context).edit().remove(PENDING_KEY).commit()
        return pending
    }

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
}
