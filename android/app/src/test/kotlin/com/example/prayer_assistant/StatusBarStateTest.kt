package com.pirci.prayer_assistant

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class StatusBarStateTest {

    private val prayerTime = 1700000000000L // arbitrary epoch timestamp
    private val nextPrayerTime = prayerTime + 4 * 3600 * 1000L // 4 hours later

    private val timeline = listOf(
        "Dhuhr" to prayerTime,
        "Asr" to nextPrayerTime
    )

    @Test
    fun emptyTimeline_returnsNull() {
        assertNull(PrayerWidgetUpdater.calculateStatusBarState(emptyList(), prayerTime))
    }

    @Test
    fun beforePrayerTime_showsUpcomingPrayerNotPostPrayer() {
        val now = prayerTime - 5 * 60 * 1000L // 5 minutes before
        val state = PrayerWidgetUpdater.calculateStatusBarState(timeline, now)

        assertNotNull(state)
        assertEquals("Dhuhr", state!!.prayer.first)
        assertEquals(prayerTime, state.prayer.second)
        assertFalse(state.isPostPrayer)
        assertEquals(0, state.postMinutes)
    }

    @Test
    fun insideFinalMinuteBeforePrayer_showsUpcomingPrayerNotPostPrayer() {
        val now = prayerTime - 30 * 1000L // 30 seconds before
        val state = PrayerWidgetUpdater.calculateStatusBarState(timeline, now)

        assertNotNull(state)
        assertEquals("Dhuhr", state!!.prayer.first)
        assertFalse(state.isPostPrayer)
        assertEquals(0, state.postMinutes)
    }

    @Test
    fun atPrayerTime_showsFirstMinutePlusOne() {
        val now = prayerTime // exactly at prayer time (0 seconds elapsed)
        val state = PrayerWidgetUpdater.calculateStatusBarState(timeline, now)

        assertNotNull(state)
        assertEquals("Dhuhr", state!!.prayer.first)
        assertTrue(state.isPostPrayer)
        assertEquals(1, state.postMinutes)
    }

    @Test
    fun insideFirstMinuteAfterPrayer_showsPlusOne() {
        val now = prayerTime + 45 * 1000L // 45 seconds elapsed
        val state = PrayerWidgetUpdater.calculateStatusBarState(timeline, now)

        assertNotNull(state)
        assertEquals("Dhuhr", state!!.prayer.first)
        assertTrue(state.isPostPrayer)
        assertEquals(1, state.postMinutes)
    }

    @Test
    fun insideSecondMinuteAfterPrayer_showsPlusTwo() {
        val now = prayerTime + 75 * 1000L // 1 minute 15 seconds elapsed
        val state = PrayerWidgetUpdater.calculateStatusBarState(timeline, now)

        assertNotNull(state)
        assertEquals("Dhuhr", state!!.prayer.first)
        assertTrue(state.isPostPrayer)
        assertEquals(2, state.postMinutes)
    }

    @Test
    fun insideThirdMinuteAfterPrayer_showsPlusThree() {
        val now = prayerTime + 135 * 1000L // 2 minutes 15 seconds elapsed
        val state = PrayerWidgetUpdater.calculateStatusBarState(timeline, now)

        assertNotNull(state)
        assertEquals("Dhuhr", state!!.prayer.first)
        assertTrue(state.isPostPrayer)
        assertEquals(3, state.postMinutes)
    }

    @Test
    fun afterThreeMinutesElapsed_revertsToUpcomingPrayer() {
        val now = prayerTime + 180 * 1000L // exactly 3 minutes (180s) elapsed
        val state = PrayerWidgetUpdater.calculateStatusBarState(timeline, now)

        assertNotNull(state)
        assertEquals("Asr", state!!.prayer.first)
        assertEquals(nextPrayerTime, state.prayer.second)
        assertFalse(state.isPostPrayer)
        assertEquals(0, state.postMinutes)
    }

    @Test
    fun tenMinutesAfterPrayer_showsUpcomingPrayer() {
        val now = prayerTime + 10 * 60 * 1000L
        val state = PrayerWidgetUpdater.calculateStatusBarState(timeline, now)

        assertNotNull(state)
        assertEquals("Asr", state!!.prayer.first)
        assertEquals(nextPrayerTime, state.prayer.second)
        assertFalse(state.isPostPrayer)
        assertEquals(0, state.postMinutes)
    }

    @Test
    fun formatCountdownText_nullState_returnsDashes() {
        assertEquals("--:--", PrayerWidgetUpdater.formatCountdownText(null, prayerTime, 60))
    }

    @Test
    fun formatCountdownText_insideFirstMinuteAfterPrayer_returnsPlusOne() {
        val nowAtPrayer = prayerTime
        val stateAtPrayer = PrayerWidgetUpdater.calculateStatusBarState(timeline, nowAtPrayer)
        assertEquals("+1", PrayerWidgetUpdater.formatCountdownText(stateAtPrayer, nowAtPrayer, 60))
        assertEquals("+1", PrayerWidgetUpdater.formatCountdownText(stateAtPrayer, nowAtPrayer, 0))

        val nowMidFirstMin = prayerTime + 45 * 1000L
        val stateMidFirstMin = PrayerWidgetUpdater.calculateStatusBarState(timeline, nowMidFirstMin)
        assertEquals("+1", PrayerWidgetUpdater.formatCountdownText(stateMidFirstMin, nowMidFirstMin, 60))
    }

    @Test
    fun formatCountdownText_insideSecondMinuteAfterPrayer_returnsPlusTwo() {
        val now = prayerTime + 75 * 1000L
        val state = PrayerWidgetUpdater.calculateStatusBarState(timeline, now)
        assertEquals("+2", PrayerWidgetUpdater.formatCountdownText(state, now, 60))
        assertEquals("+2", PrayerWidgetUpdater.formatCountdownText(state, now, 0))
    }

    @Test
    fun formatCountdownText_insideThirdMinuteAfterPrayer_returnsPlusThree() {
        val now = prayerTime + 135 * 1000L
        val state = PrayerWidgetUpdater.calculateStatusBarState(timeline, now)
        assertEquals("+3", PrayerWidgetUpdater.formatCountdownText(state, now, 60))
        assertEquals("+3", PrayerWidgetUpdater.formatCountdownText(state, now, 0))
    }

    @Test
    fun formatCountdownText_afterThreeMinutes_returnsUpcomingPrayerCountdown() {
        val now = prayerTime + 180 * 1000L
        val state = PrayerWidgetUpdater.calculateStatusBarState(timeline, now)
        // Asr is 4 hours after Dhuhr, minus 3 minutes = 3 hours 57 minutes remaining
        assertEquals("3:57", PrayerWidgetUpdater.formatCountdownText(state, now, 60))
    }
}

