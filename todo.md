# Planned Features

## 1. Audio Adhan at Prayer Times [DONE]
- [x] Add `adhanEnabled` field to `ReminderSetting` model (with serialization, copyWith, legacy support)
- [x] Add adhan notification channels: `prayer_reminders_adhan_vibrate_sound` and `prayer_reminders_adhan_sound_only`
- [x] Add "Adhan" FilterChip in ReminderSettingsScreen alert section (disabled when sound is off)
- [x] Pass adhanEnabled through notification scheduling: model -> controller -> notification service
- [x] Localized "Adhan" label across all 12 languages
- [x] Sound file placed at `android/app/src/main/res/raw/adhan.wav`
- [x] Stale channel cleanup fixed to not delete adhan channels

## 2. Prayer Tracking (Completed/Missed)
Track which prayers the user has completed each day.
- Add completed/missed state per prayer per day
- Tap a prayer row to toggle completed status
- Daily completion summary and streak counter
- Persist to local database

## 3. Islamic Holidays on Calendar [DONE]
- [x] Define 10 Islamic holidays with Hijri month/day in hijri_utils.dart
- [x] Add `islamicHolidayForDate()` lookup function
- [x] Highlight holiday cells on calendar grid (amber border and tint)
- [x] Show holiday name in day detail sheet with star icon
