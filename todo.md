# Planned Features

## 1. Audio Adhan at Prayer Times [DONE]
- [x] Add `adhanEnabled` field to `ReminderSetting` model (with serialization, copyWith, legacy support)
- [x] Add adhan notification channels: `prayer_reminders_adhan_vibrate_sound` and `prayer_reminders_adhan_sound_only`
- [x] Add "Adhan" FilterChip in ReminderSettingsScreen alert section (disabled when sound is off)
- [x] Pass adhanEnabled through notification scheduling: model -> controller -> notification service
- [x] Localized "Adhan" label across all 12 languages
- [x] Sound file placed at `android/app/src/main/res/raw/adhan.wav`
- [x] Stale channel cleanup fixed to not delete adhan channels

## 2. Prayer Tracking (Completed/Missed) [DONE]
Track which prayers the user has completed each day.
- [x] Add completed/missed state per prayer per day
- [x] Tap a prayer row to toggle completed status
- [x] Daily completion summary on home screen and history table
- [x] Persist to local database (SQLite app_settings)

## 3. Islamic Holidays on Calendar [DONE]
- [x] Define 10 Islamic holidays with Hijri month/day in hijri_utils.dart
- [x] Add `islamicHolidayForDate()` lookup function
- [x] Highlight holiday cells on calendar grid (amber border and tint)
- [x] Show holiday name in day detail sheet with star icon

## 4. Prayer Consistency Analytics & Streaks [DONE]
Visual dashboard and insights into prayer completion habits.
- [x] Current & longest streak counters
- [x] Monthly prayer completion heatmap grid
- [x] Completion rate breakdown by prayer (Fajr, Dhuhr, Asr, Maghrib, Isha)


## 5. Kaza (Qadaa) Missed Prayer Calculator & Tracker [DONE]
Track missed past prayers that need to be made up.
- [x] Counter per prayer (Fajr, Dhuhr, Asr, Maghrib, Isha, Witr)
- [x] Increment / decrement completion counts
- [x] Estimated completion date calculation based on daily pace
- [x] Dedicated bottom navigation tab (placed directly left of Today)



## 6. Ramadan & Voluntary Fasting (Sawm) Assistant
Support for Ramadan and Sunnah fasts throughout the year.
- [ ] Iftar & Suhoor live countdown timers
- [ ] Notifications for Monday/Thursday & White Days (13th, 14th, 15th Hijri)
- [ ] Annual fasting habit logger

## 7. Daily Wisdom & Supplications (Hisn al-Muslim) [DONE]
- [x] Rotating Ayah/Hadith card on Home screen with share option, Arabic text, transliteration & multi-language support
- [x] Essential supplications library with integrated counter and 5 category collections (Hisn al-Muslim)


## 8. Backup & Export [DONE]
Data portability options in Preferences screen.
- [x] Comprehensive JSON Backup & Restore:
  - [x] Export/import Qadaa (Kaza) targets, completion counts & daily pace settings
  - [x] Export/import daily prayer completion history
  - [x] Export/import Tesbihat counters, custom beads & group memberships
  - [x] Export/import custom calendar reminders & notes
  - [x] Export/import app preferences & saved location data
- [x] iCalendar Export (.ics):
  - [x] Export 10 Islamic holidays & important dates to `.ics` format




