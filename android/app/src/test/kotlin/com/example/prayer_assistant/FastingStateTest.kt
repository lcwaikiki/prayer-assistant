package com.pirci.prayer_assistant

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.Calendar

class FastingStateTest {
    private val widgetStrings = PrayerWidgetUpdater.getWidgetStrings("en")

    private fun makeCalendar(year: Int, month: Int, day: Int, hour: Int, minute: Int): Long {
        val cal = Calendar.getInstance()
        cal.set(year, month - 1, day, hour, minute, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return cal.timeInMillis
    }

    private fun makeDaySchedule(year: Int, month: Int, day: Int): List<PrayerWidgetStorage.PrayerEntry> {
        return listOf(
            PrayerWidgetStorage.PrayerEntry("Imsak", "imsak", makeCalendar(year, month, day, 5, 0)),
            PrayerWidgetStorage.PrayerEntry("Sunrise", "gunes", makeCalendar(year, month, day, 6, 30)),
            PrayerWidgetStorage.PrayerEntry("Dhuhr", "ogle", makeCalendar(year, month, day, 12, 30)),
            PrayerWidgetStorage.PrayerEntry("Asr", "ikindi", makeCalendar(year, month, day, 16, 0)),
            PrayerWidgetStorage.PrayerEntry("Maghrib", "aksam", makeCalendar(year, month, day, 19, 0)),
            PrayerWidgetStorage.PrayerEntry("Isha", "yatsi", makeCalendar(year, month, day, 20, 30))
        )
    }

    @Test
    fun duringFastingHours_showsTimeToIftar() {
        val day1Schedule = makeDaySchedule(2026, 11, 2)
        val day2Schedule = makeDaySchedule(2026, 11, 3)
        val schedule = day1Schedule + day2Schedule

        val now = makeCalendar(2026, 11, 2, 10, 0)
        val state = PrayerWidgetUpdater.calculateFastingState(
            now = now,
            schedule = schedule,
            todayDetailed = day1Schedule,
            timelineDetailed = emptyList(),
            widgetStrings = widgetStrings
        )

        assertTrue(state.isFastingHours)
        assertEquals("Time to Iftar", state.title)
        assertEquals(makeCalendar(2026, 11, 2, 19, 0), state.targetEpoch)
        assertEquals("Iftar: 19:00", state.targetTimeLabel)
    }

    @Test
    fun eveningAfterIftar_showsTimeToSuhoorTargetingNextMorning() {
        val day1Schedule = makeDaySchedule(2026, 11, 2)
        val day2Schedule = makeDaySchedule(2026, 11, 3)
        val schedule = day1Schedule + day2Schedule

        val now = makeCalendar(2026, 11, 2, 21, 0)
        val state = PrayerWidgetUpdater.calculateFastingState(
            now = now,
            schedule = schedule,
            todayDetailed = day1Schedule,
            timelineDetailed = emptyList(),
            widgetStrings = widgetStrings
        )

        assertFalse(state.isFastingHours)
        assertEquals("Time to Suhoor", state.title)
        assertEquals(makeCalendar(2026, 11, 3, 5, 0), state.targetEpoch)
        assertEquals("Suhoor: 05:00", state.targetTimeLabel)
    }

    @Test
    fun earlyMorningBeforeSuhoor_showsTimeToSuhoorTargetingTodayMorning() {
        val day1Schedule = makeDaySchedule(2026, 11, 2)
        val day2Schedule = makeDaySchedule(2026, 11, 3)
        val schedule = day1Schedule + day2Schedule

        val now = makeCalendar(2026, 11, 3, 3, 0)
        val state = PrayerWidgetUpdater.calculateFastingState(
            now = now,
            schedule = schedule,
            todayDetailed = day2Schedule,
            timelineDetailed = emptyList(),
            widgetStrings = widgetStrings
        )

        assertFalse(state.isFastingHours)
        assertEquals("Time to Suhoor", state.title)
        assertEquals(makeCalendar(2026, 11, 3, 5, 0), state.targetEpoch)
        assertEquals("Suhoor: 05:00", state.targetTimeLabel)
    }
}

