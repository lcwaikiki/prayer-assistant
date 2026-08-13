# Prayer Assistant — Plan

Living document: feature inventory of the app as it stands, plus a running
todo checklist. Check items off as they're completed; add new ones as work
comes in.

## Architecture at a glance

- **State**: `PrayerAppController` (Provider `ChangeNotifier`) drives
  location, prayer data, preferences, and calendar reminders. Tesbihat
  (beads) items use Riverpod (`ItemsNotifier`) instead — two state
  frameworks coexist in this app, by design.
- **Storage**: `LocalDatabase` (sqflite) holds the prayer-times cache, all
  scalar settings, and calendar reminders. Tesbihat items live in a Hive
  box (`ItemRepository`).
- **Notifications**: three independent `flutter_local_notifications`
  consumers, each with its own Android channel(s) and a non-colliding
  notification-id range:
  - Prayer reminders — ids `1-48` (`NotificationService`)
  - Tesbih/dhikr reminders — ids `800000-899999` (`ItemReminderService`)
  - Calendar reminders — ids `700000-799999` (`CalendarReminderService`)
- **Background refresh**: two Android-only `AndroidAlarmManager.periodic`
  jobs run just after midnight to re-resolve reminders whose fire time
  can't be a fixed OS-level repeat (prayer-anchored and yearly-Hijri
  reminders): `MidnightReminderScheduler` (tesbih, alarm id `5001`) and
  `CalendarMidnightScheduler` (calendar, alarm id `5002`). iOS has no
  background-alarm equivalent, so these refresh on next app open instead.
- **Localization**: `flutter gen-l10n` (`AppLocalizations`) covers the main
  app across 11 locales; Tesbihat has its own `TesbihatLocalizations`
  delegate. English and Turkish are fully translated; other locales fall
  back to English for newer strings.

## Features

### Location
- GPS auto-detect or manual Country → State/City → District picker.
- Backed by a Diyanet-style prayer-times API (`ImsakiyemApi`).

### Today tab
- Edge-to-edge layout, list of today's prayer times with the upcoming
  prayer's row/time highlighted, live countdown to the next prayer.
- Per-prayer reminder settings: on-time / before (with preset + custom
  minutes), per-prayer vibrate/sound override, global reminders on/off and
  vibrate/sound switches.
- Quick-toggle app-bar icons (reminders on/off, light/dark) on every tab.

### Dates tab
Two sub-tabs:
- **Prayer Times** — full current-year table (per-day imsak/gunes/ogle/
  ikindi/aksam/yatsi + API-sourced Hijri date string), scroll-to-today FAB.
- **Calendar** — monthly Hijri/Gregorian grid:
  - Primary calendar switchable (segmented button: Hijri/Gregorian);
    secondary date show/hide toggle.
  - Month navigation steps correctly in whichever calendar is primary.
  - Today highlight, per-day reminder dot markers.
  - Tapping a day opens a bottom sheet listing that day's reminders
    (enable/disable, edit, delete) and an "add reminder" action.
  - Reminders: title + optional notes, anchored to either a calendar
    date/time or a prayer time (+ before/on-time/after offset, same
    chip-and-custom-minutes picker style as prayer/tesbih reminders).
    Recurrence: once, daily, weekly, monthly, yearly — yearly can follow
    either the Gregorian date or the true Hijri date (drifts ~11
    days/year earlier in the Gregorian calendar), chosen per reminder.
    Prayer-time-anchored reminders are implicitly daily-recurring.
  - Tapping a calendar-reminder notification opens the calendar to today
    and shows that day's reminders.

### Beads (Tesbihat) tab
- Dhikr/counter items: count, checkpoint interval, vibration intensity,
  notes, reorder, edit/delete with undo.
- Per-item reminders: once/daily clock-time, or prayer-time-anchored with
  offset; tapping a reminder notification opens that item's counter screen.

### Preferences
- Language (system default + 11 locales), theme mode (system/light/dark),
  home app-bar remaining-time placement, widget text size, reminders
  on/off, reminder vibration/sound toggles.

### Home screen widgets (Android)
- Configurable text size, kept in sync with prayer data.

## Todo checklist

### Hijri calendar + reminders — initial build
- [x] Monthly Hijri/Gregorian calendar screen (switchable primary,
      show/hide secondary, reachable from the Dates tab)
- [x] Standalone calendar reminders: once/daily/weekly/monthly/yearly
      (Gregorian or Hijri basis)
- [x] Offline Hijri↔Gregorian conversion (`hijri` package), no dependency
      on the per-day API string for calendar browsing

### Follow-up polish round
- [x] Tapping a calendar-reminder notification navigates to that date's
      reminders (day-detail sheet)
- [x] Prayer-time before/after anchor option on the calendar reminder edit
      screen (mirrors the tesbih item form's chip-and-custom-minutes style)
- [x] Clearer switch between the Prayer Times table and the Calendar (Dates
      tab is now a two-tab `TabBar`, not a small icon button)
- [x] Bigger calendar grid (taller cells, larger fonts, tighter padding)
- [x] Month/year title no longer truncated (moved out of the cramped
      app-bar row into a full-width, two-line-capable header)
- [x] Turkish translations completed for all calendar/reminder strings
- [x] Full translations for the remaining 9 locales (ar, de, es, fa, fr,
      id, ja, ur, zh) — also caught and fixed a pre-existing gap: the
      widget-text-size settings strings were missing translations in all
      9 of these locales even before this feature, not just the new
      calendar/reminder strings. All 11 locales now have 0 missing keys
      vs. the English template.
- [x] Manual runtime check on an Android emulator (Pixel 7 Pro, API 34):
      clean build/install/launch, sqflite v3 migration, Dates tab's new
      Prayer Times/Calendar `TabBar`, Hijri↔Gregorian primary switch, month
      navigation and full-width month title, day-detail sheet, and the new
      reminder form (calendar-date/prayer-time segmented switch, recurrence
      chips) all confirmed visually on-device and cross-checked against
      each other (e.g. 30 Safar 1448 ⇔ Aug 13 2026 in both calendar modes)
- [ ] Confirm an actual notification fires and the tap-to-open-day-sheet
      deep link works on-device — blocked this round by the emulator
      itself becoming unresponsive (ANR) under its software GL renderer
      during picker-dialog interaction; logcat showed no app exceptions,
      so this reads as emulator/host performance, not app code. The
      firing logic is a close structural mirror of `ItemReminderService`/
      `MidnightReminderScheduler`, which already work for tesbih
      reminders, but that's inference, not a confirmed live test. Retry
      on a less loaded emulator or a physical device.
- [x] Calendar reminder deletion now uses the same undo mechanism as
      Beads item deletion: deletes immediately (no confirm dialog),
      shows a 6-second Snackbar with an Undo action that re-inserts the
      reminder at its original position and reschedules its
      notification. The day-detail sheet is now reactive (`context.watch`)
      so it updates live instead of needing to be reopened.
- [x] Calendar reminder add/update/delete/restore now call
      `notifyListeners()` immediately after the in-memory list changes
      (before awaiting the DB save / notification scheduling), matching
      the Beads pattern — fixes the calendar grid lagging or, in the
      worst case, silently never refreshing if a scheduling call ever
      threw.

### Ideas / not started
- [x] Monthly recurrence on a Hijri day-of-month: `CalendarReminder` now
      has a `monthlyBasis` (`CalendarBasis.gregorian`/`.hijri`, the same
      enum yearly already used — renamed from `YearlyCalendarBasis` to
      `CalendarBasis` since it's shared now). Hijri-basis monthly
      reminders compute their next Gregorian occurrence the same way
      yearly-Hijri does and are re-resolved by the daily midnight
      scheduler (no native OS repeat for a floating Hijri day-of-month).
      Reminder form shows a Gregorian/Hijri chip picker when recurrence
      is Monthly, mirroring the Yearly one.
- [x] In-app "Upcoming reminders" card on the Today tab: shows the next
      3 enabled calendar reminders (via `CalendarReminder.nextOccurrenceFrom`,
      which reuses `occursOn` to scan forward), tapping one opens the
      calendar on that date's day-detail sheet. Only rendered when
      there's at least one upcoming reminder, so it doesn't disturb the
      edge-to-edge Today tab layout when there's nothing to show.
- [ ] Android home-screen widget surface for upcoming calendar reminders
      — separate from the in-app card above; needs native Kotlin/XML
      changes to the existing prayer-times widget and can't be verified
      without deploying to a real device. Not started.
