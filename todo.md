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

## 4. Prayer Consistency Analytics & Streaks
Visual dashboard and insights into prayer completion habits.
- [ ] Current & longest streak counters
- [ ] Monthly prayer completion heatmap grid
- [ ] Completion rate breakdown by prayer (Fajr, Dhuhr, Asr, Maghrib, Isha)

## 5. Kaza (Qadaa) Missed Prayer Calculator & Tracker
Track missed past prayers that need to be made up.
- [ ] Counter per prayer (Fajr, Dhuhr, Asr, Maghrib, Isha, Witr)
- [ ] Increment / decrement completion counts
- [ ] Estimated completion date calculation based on daily pace

## 6. Ramadan & Voluntary Fasting (Sawm) Assistant
Support for Ramadan and Sunnah fasts throughout the year.
- [ ] Iftar & Suhoor live countdown timers
- [ ] Notifications for Monday/Thursday & White Days (13th, 14th, 15th Hijri)
- [ ] Annual fasting habit logger

## 7. Daily Wisdom & Supplications (Hisn al-Muslim) [DONE]
- [x] Rotating Ayah/Hadith card on Home screen with share option, Arabic text, transliteration & multi-language support
- [x] Essential supplications library with integrated counter and 5 category collections (Hisn al-Muslim)


## 8. Backup & Export
- [ ] Export/import app settings, prayer history & tesbihat counters to JSON
- [ ] Export yearly prayer schedule & holidays to .ics calendar format

