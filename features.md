# Prayer Assistant — App Store Feature Document

Feature inventory of the app, suitable for preparing app-store listings
(Google Play, App Store). All items are factual, derived from the codebase.

## App identity

- **Name**: Prayer Assistant (localized per device language, e.g. "Namaz Asistanı" in Turkish, "Asistente de Oración" in Spanish, "مساعد الصلاة" in Arabic)
- **Suggested tagline**: Islamic daily practice, all in one app — prayer times, Hijri calendar, Qibla, and digital dhikr
- **Category**: Lifestyle / Education / Productivity
- **Version**: 1.0.0
- **Platforms**: Android (full feature set), iOS (core features)

## Suggested store description

Prayer Assistant brings together everything you need for daily Islamic
practice: accurate prayer times with reminders, an offline Hijri
calendar, Qibla direction, and a digital dhikr (tesbih) counter with
full reminder support — all localized for 12 languages and designed to
work offline.

## Features

### Prayer times
- Daily prayer times for the six prayer periods (Imsak, Sunrise, Dhuhr, Asr, Maghrib, Isha) with live "next prayer" countdown banner that updates every second
- Full-year prayer schedule per location, cached locally — the app stays fully usable offline after the first sync
- Six-prayer table with "today" highlighted and per-prayer reminder status
- Share today's prayer times as text (native share sheet)
- Location auto-detection via GPS with fuzzy matching, or manual selection by country / state / district
- Daily prayer times home-screen widget (Android): 3×2 widget with all six prayers and the next one highlighted

### Prayer reminders
- Reminders on-time, before, or after each prayer with presets (5–60 min) or custom 1–240 minutes
- Per-prayer vibration and sound overrides combined with global reminder switches
- Global master switch for reminders, plus global vibration and sound toggles
- Persistent status-bar notification showing minutes remaining until the next prayer (Android)
- Notifications survive reboot: alarms are re-registered on boot and app update

### Qibla
- Live compass showing the Qibla direction (great-circle bearing to the Kaaba, Mecca) using the device magnetometer
- Bearing in degrees and current GPS coordinates; static dial fallback when no magnetometer is available

### Hijri / Gregorian calendar
- Full calendar in either Hijri or Gregorian primary mode, with optional secondary date display on every day
- Locale-aware month names (native Arabic for Arabic users), weekday headers, and today highlighting
- Offline Hijri ↔ Gregorian conversion (no network required)
- Month/year navigation in whichever calendar is primary, with jump-to-today
- Day detail sheet: both calendar dates, that day's prayer times, and that day's reminders

### Calendar reminders
- Reminders anchored to a fixed date/time or to a prayer time (on-time / before / after, presets or custom minutes)
- Recurrence: once, daily, weekly (multi-select weekdays), monthly (day of month), yearly (month + day)
- Monthly and yearly recurrence available in Gregorian or Hijri basis — Hijri anniversaries are handled correctly as they drift through the Gregorian year
- Optional repeat count (2–100) so a reminder can fire a limited number of times and stop
- Reminder dots on calendar days, delete with undo, and tapping a reminder notification opens the calendar at that day

### Dhikr (tesbih) counter — "Beads"
- Create unlimited dhikr beads with name, notes, target count, and checkpoint interval
- One-tap counting with live progress bar and remaining count; set count auto-increments each time a target is reached
- Haptic feedback tuned to intensity: standard taps vs. checkpoint taps, with real vibrator amplitude control on supported devices
- Long-press to edit progress and completed sets; reset with confirmation; notes panel; screen stays awake while counting
- Reorder beads, edit, delete with undo
- Daily activity statistics: today, last 7 days, and all-time tap counts

### Bead groups
- Organize beads into groups (one level); a bead can belong to multiple groups
- Group cards on the home screen with member counts and reminder status
- Add existing beads to a group or create a new bead directly inside a group; remove beads from groups
- Groups are containers only — counting happens on the individual bead

### Bead & group reminders
- Full reminder support identical for beads and groups: clock-time or prayer-time anchor
- Recurrence: once, daily, weekly, monthly, yearly — monthly/yearly in Gregorian or Hijri basis
- Repeat count (2–100), weekdays, day-of-month, yearly date, and prayer-offset options
- Tapping a bead reminder opens that bead's counter; tapping a group reminder opens the group

### Personalization
- 12 UI languages: English, Spanish, French, German, Turkish, Urdu, Persian (Farsi), Arabic, Chinese, Japanese, Indonesian, Russian — plus "follow system"
- Light / dark / system theme with quick toggle in the app bar
- App-bar layout options: remaining-time label in title, as chip, as subtitle, or hidden
- Widget text size (extra small → large) and MM:SS countdown threshold (0–60 min) for Android widgets

### Android home-screen widgets
- Next Prayer (3×2)
- Remaining Time (2×2)
- Remaining Time Circle (1×1 circular countdown)
- Daily Prayer Times (3×2)
- Upcoming Reminders (3×3)
- Tapping any widget opens the app; widget data updates live from the app

### Reliability & offline behavior
- Full-year prayer data cached per location: offline-first after first sync
- Midnight background refresh (Android) re-resolves prayer-anchored and Hijri-basis reminders daily
- Exact-alarm scheduling where permitted, with automatic inexact fallback
- Four notification channels so per-prayer vibration/sound behavior is honored even on Android
- Timezone-aware scheduling using the device timezone

## Platform coverage

| Feature | Android | iOS |
|---|---|---|
| Prayer times & reminders | Yes | Yes |
| Hijri calendar & calendar reminders | Yes | Yes |
| Qibla compass | Yes | Yes |
| Dhikr counter & groups | Yes | Yes |
| Home-screen widgets | Yes (5 widgets) | No |
| Status-bar remaining-time notification | Yes | No |
| Background midnight reminder refresh | Yes (alarm job) | On next app open |
| Exact-alarm scheduling | Yes | n/a |

## Languages

en, es, fr, de, tr, ur, fa, ar, zh, ja, id, ru (+ system default)

## Key limits to note in store copy

- Prayer-time data source covers the locations served by the ezanvakti.imsakiyem.com (Diyanet-style) API; GPS selection only matches within that list
- Times are always shown in 24-hour format
- Exact alarms require the user to grant the exact-alarm permission on Android 12+
- Widgets and status-bar notification are Android-only

## Not ready for the store yet (housekeeping)

- `pubspec.yaml` description is still the Flutter placeholder ("A new Flutter project.")
- Android package id is `com.example.prayer_assistant` — should be changed to a real reverse-domain id before release
- No app-store screenshots or feature graphic exist yet