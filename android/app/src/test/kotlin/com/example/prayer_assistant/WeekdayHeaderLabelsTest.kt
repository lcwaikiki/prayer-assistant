package com.pirci.prayer_assistant

import org.junit.Assert.assertEquals
import org.junit.Test

class WeekdayHeaderLabelsTest {
    // ICU shortWeekdays layout: index 0 empty, 1=Sunday .. 7=Saturday.
    private val shortWeekdays = listOf(
        "", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
    )

    @Test
    fun mondayFirst_ordersMondayThroughSunday() {
        val result = PrayerWidgetUpdater.orderWeekdayLabels(shortWeekdays, sundayFirst = false)
        assertEquals(
            listOf("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"),
            result
        )
    }

    @Test
    fun sundayFirst_ordersSundayThroughSaturday() {
        val result = PrayerWidgetUpdater.orderWeekdayLabels(shortWeekdays, sundayFirst = true)
        assertEquals(
            listOf("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"),
            result
        )
    }
}
