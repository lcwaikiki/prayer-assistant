# Planned Features

## 1. Audio Adhan at Prayer Times [DONE]
Add an adhan (ezan) sound option that plays when prayer time arrives.
- [x] Add `adhanEnabled` field to `ReminderSetting` model (with serialization, copyWith, legacy support)
- [x] Add adhan notification channels: `prayer_reminders_adhan_vibrate_sound` and `prayer_reminders_adhan_sound_only`
- [x] Add "Adhan" FilterChip in ReminderSettingsScreen alert section (disabled when sound is off)
- [x] Pass adhanEnabled through notification scheduling: model -> controller -> notification service
- [x] Localized "Adhan" label across all 12 languages
- [ ] Sound file: Place an adhan audio file at `android/app/src/main/res/raw/adhan.wav` (or .mp3)
- [ ] Note: `soundEnabled` must be on for Adhan to take effect (global + per-prayer)

## 2. Prayer Tracking (Completed/Missed)
Track which prayers the user has completed each day.
- Add completed/missed state per prayer per day
- Tap a prayer row to toggle completed status
- Daily completion summary and streak counter
- Persist to local database

## 3. Islamic Holidays on Calendar
Show Islamic holidays on the Hijri calendar grid.
- Mark Eid al-Fitr, Eid al-Adha, Laylat al-Qadr, Ashura, Mawlid, etc.
- Highlight special days on calendar cells
- Use Hijri date calculations from the `hijri` package
