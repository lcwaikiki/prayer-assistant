package com.pirci.prayer_assistant

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Test

class BeadOverlayThemeTest {
    @Test
    fun lightMode_usesLightPalette() {
        val theme = BeadOverlay.getDismissTheme(isDark = false)
        assertEquals("#FFFFFFFF", theme.normalBgColor)
        assertEquals("#CCCCCC", theme.normalStrokeColor)
        assertEquals("#3C4043", theme.normalTextColor)
        assertEquals("#E53935", theme.activeBgColor)
        assertEquals("#C62828", theme.activeStrokeColor)
        assertEquals("#FFFFFF", theme.activeTextColor)
    }

    @Test
    fun darkMode_usesDarkPalette() {
        val theme = BeadOverlay.getDismissTheme(isDark = true)
        assertEquals("#202124", theme.normalBgColor)
        assertEquals("#5F6368", theme.normalStrokeColor)
        assertEquals("#F1F3F4", theme.normalTextColor)
        assertEquals("#E53935", theme.activeBgColor)
        assertEquals("#FF8A80", theme.activeStrokeColor)
        assertEquals("#FFFFFF", theme.activeTextColor)
    }

    @Test
    fun palettesDifferForDarkAndLightMode() {
        val lightTheme = BeadOverlay.getDismissTheme(isDark = false)
        val darkTheme = BeadOverlay.getDismissTheme(isDark = true)

        assertNotEquals(lightTheme.normalBgColor, darkTheme.normalBgColor)
        assertNotEquals(lightTheme.normalStrokeColor, darkTheme.normalStrokeColor)
        assertNotEquals(lightTheme.normalTextColor, darkTheme.normalTextColor)
        assertNotEquals(lightTheme.activeStrokeColor, darkTheme.activeStrokeColor)
    }
}

