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
- Per-item reminders: once/daily/weekly/monthly/yearly clock-time
  (Gregorian or Hijri basis), or prayer-time-anchored with offset and the
  same recurrence options; tapping a reminder notification opens that
  item's counter screen.

### Preferences
- Language (system default + 11 locales), theme mode (system/light/dark),
  home app-bar remaining-time placement, widget text size, reminders
  on/off, reminder vibration/sound toggles.

### Home screen widgets (Android)
- Configurable text size, kept in sync with prayer data.

## Todo checklist

### Beads reminder parity with calendar reminders
- [x] Beads item reminders now support the full calendar-reminder recurrence
      set: once / daily / weekly / monthly / yearly, with monthly and yearly
      able to follow either the Gregorian date or the true Hijri date (shared
      `ReminderRecurrence`/`CalendarBasis` enums from the calendar module).
      `Item.reminderRepeat` (once/daily) is replaced by
      `reminderRecurrence` + `reminderMonthlyBasis`/`reminderYearlyBasis`;
      legacy Hive entries migrate on load via the old `reminderRepeat` value.
- [x] `ItemReminderService` now schedules weekly (day-of-week repeat), monthly
      (day-of-month repeat, or a one-shot on the next Hijri day-of-month) and
      yearly (date repeat, or a one-shot on the next Hijri anniversary)
      exactly like `CalendarReminderService`; prayer-anchored items stay
      implicitly daily-recurring with the same catch-up-window behavior.
- [x] Recurrence now applies to **prayer-time anchored** beads reminders too
      (was implicitly daily only). New `Item.reminderAnchorDate` anchors the
      recurrence (weekday for weekly, day-of-month for monthly, month/day for
      yearly); the schedule is a one-shot resolved to the next matching
      occurrence's own prayer time (via `resolvePrayerAnchoredTime` with a
      `date`), advanced each midnight. Legacy prayer-time items (no anchor
      date) migrate to daily, preserving their original behavior.
- [x] `MidnightReminderScheduler` re-schedules prayer-anchored and Hijri-basis
      monthly/yearly item reminders each midnight (no native OS repeat for a
      floating prayer time or Hijri day), matching `CalendarMidnightScheduler`.
- [x] Item form shows the recurrence chips (once/daily/weekly/monthly/yearly)
      plus Gregorian/Hijri basis pickers for monthly and yearly; the date/time
      picker and reminder label handle every recurrence the same way the
      calendar reminder form does. The prayer-time branch now shows the same
      recurrence chips and basis pickers plus an anchor-date picker
      (defaults to today; hidden for daily).
- [x] New recurrence/basis strings translated into all 10 Tesbihat locales.

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
- [x] Android home-screen widget surface for upcoming calendar reminders:
      a new `UpcomingRemindersWidgetProvider` (3rd widget alongside the
      existing Next Prayer / Remaining Time ones), following the same
      SharedPreferences-backed pattern as `PrayerWidgetStorage`/
      `PrayerWidgetUpdater`. `PrayerAppController` pushes the next 3
      enabled reminders — pre-formatted with `DateFormat`/`AppLocalizations`
      on the Dart side, since the native layer has no l10n access — via
      a new `updateCalendarReminders` method channel call, fired
      immediately after every add/update/delete/restore and once on
      `initialize()`. Fixed 3-row `RemoteViews` layout (no
      `RemoteViewsService`/ListView — deliberately simple for a 3-item
      display), tapping it opens the app to the Today tab like the other
      widgets. Verified: clean `flutter build apk --debug` (Kotlin +
      resources compile) and a clean install/launch on a real device
      (Galaxy Z Flip) with no crash in logcat. **Not verified by me**:
      actually adding the widget to a home screen and confirming it
      renders live data — an attempt at scripted UI automation on the
      user's physical phone mis-tapped into an unrelated app (a floating
      overlay intercepted a tap), so at the user's choice this final
      manual check (add a reminder, long-press home screen → widgets →
      "Prayer Assistant" → Upcoming reminders) is left for the user to
      do themselves rather than risk more automated taps on their device.
