package com.pirci.prayer_assistant

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class WidgetPaletteTest {
    @Test
    fun explicitLight_isLightRegardlessOfSystem() {
        assertTrue(PrayerWidgetUpdater.themeIsLight("light", systemNightMode = false))
        assertTrue(PrayerWidgetUpdater.themeIsLight("light", systemNightMode = true))
    }

    @Test
    fun explicitDark_isDarkRegardlessOfSystem() {
        assertFalse(PrayerWidgetUpdater.themeIsLight("dark", systemNightMode = false))
        assertFalse(PrayerWidgetUpdater.themeIsLight("dark", systemNightMode = true))
    }

    @Test
    fun transparent_isDarkRegardlessOfSystem() {
        assertFalse(PrayerWidgetUpdater.themeIsLight("transparent", systemNightMode = false))
        assertFalse(PrayerWidgetUpdater.themeIsLight("transparent", systemNightMode = true))
    }

    @Test
    fun system_followsNightMode() {
        assertTrue(PrayerWidgetUpdater.themeIsLight("system", systemNightMode = false))
        assertFalse(PrayerWidgetUpdater.themeIsLight("system", systemNightMode = true))
    }
}
