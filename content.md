# Prayer Assist — Full Project Analysis

A Flutter mobile app (Android + iOS) for Islamic daily practice: prayer times,
Hijri/Gregorian calendar with reminders, Qibla direction, and a digital dhikr
(tesbih) counter. Prayer data comes from a Diyanet-style API
(`ezanvakti.imsakiyem.com`); after the yearly schedule is cached, reminders and
the calendar work fully offline. Android gets an extra native layer: five
home-screen widgets plus a persistent status-bar countdown notification.

---

## 1. Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart SDK `^3.12.2`), Material 3 |
| State | `provider` `ChangeNotifier` (`PrayerAppController`) + `flutter_riverpod` (`ItemsNotifier` for Beads) |
| Storage | `sqflite` (`LocalDatabase`, DB `prayer_assistant.db` v7) + Hive boxes (`items_box`, `item_history_box`) |
| Notifications | `flutter_local_notifications` (three independent producers) |
| Background (Android) | `android_alarm_manager_plus` daily midnight jobs + native `AlarmManager` exact alarms |
| Networking | `http` client; `geolocator` + `geocoding` for GPS auto-pick |
| Localization | `flutter gen-l10n`, 12 locales + separate `TesbihatLocalizations` delegate |
| Other | `intl`, `timezone`, `flutter_timezone`, `hijri`, `share_plus`, `flutter_compass`, `vibration`, `wakelock_plus`, `hive_flutter` |
| Version | 1.0.0+1 |

---

## 2. Architecture at a glance

- **`PrayerAppController`** (lib/src/controller/prayer_app_controller.dart, 794
  lines) is the single source of truth for: selected location, today's
  `PrayerDay`, the full-year `_yearRange` list, per-prayer `ReminderSetting`
  map, app-bar placement, widget text size, MM:SS threshold, theme/locale
  preferences, reminder toggles, and calendar reminders. Notifies via
  `ChangeNotifier`.
- **Tesbihat (Beads)** uses Riverpod instead: `itemsNotifierProvider` /
  `groupsNotifierProvider` (`NotifierProvider`). Two state frameworks coexist
  by design.
- **Three notification producers**, each with its own Android channel(s) and a
  non-colliding ID range:
  - Prayer reminders — ids `1..48` (`NotificationService`), test id `900001`
  - Calendar reminders — ids `700000..799999` (`CalendarReminderService`)
  - Tesbih reminders — ids `800000..899999` (`ItemReminderService`)
- **One shared tap router**: all payloads funnel through
  `handleNotificationTap(payload)` (lib/src/services/notification_tap_handler.dart)
  which dispatches on payload prefixes `calendar_reminder:`, `tesbih_item:`,
  `tesbih_group:` via the root navigator key.
- **Two Android-only midnight alarm jobs** re-resolve reminders whose fire time
  can't be a fixed OS repeat (prayer-anchored and Hijri-basis reminders):
  `MidnightReminderScheduler` (tesbih, alarm id `5001`) and
  `CalendarMidnightScheduler` (calendar, alarm id `5002`). iOS has no
  background-alarm equivalent; those refresh on next app open.
- **Widget bridge**: `WidgetBridgeService` (Dart) ↔ `MainActivity` (Kotlin)
  over `MethodChannel('prayer_assistant/widget')`. The Dart side pushes
  pre-localized, pre-formatted data; native side stores it in SharedPreferences
  and renders widgets with `RemoteViews`.

---

## 3. App entry and shell

**`lib/main.dart`** — initializes date formatting, Hive boxes, services
(`CalendarReminderService`, `PrayerAppController`, `ItemReminderService`,
both midnight schedulers), then `runApp(ProviderScope(...))`. Notification
launch payloads are handled after the first frame
(`handleAppLaunchFromNotification()`). Theme: `ColorScheme.fromSeed(0xFF1F8A70)`,
light + dark, Material 3.

**`AppShell`** (lib/src/ui/app_shell.dart) — 4 bottom-nav tabs kept alive in a
lazy `IndexedStack` (state survives tab switches):

| # | Tab | Screen |
|---|---|---|
| 0 | Qibla | `QiblaScreen` (explore icon) |
| 1 | Today | `HomeScreen` (mosque icon) |
| 2 | Dates | `HistoryScreen` (calendar icon) |
| 3 | Beads | `TesbihHomeScreen` (circle icon) |

Shared `AppBar`: tab title with optional remaining-minutes placement (title /
subtitle / trailing chip / hidden — configurable, only on the Today tab), plus
quick icons: reminders on/off, light/dark toggle, preferences. A 30-second
`Timer` refreshes the remaining-minutes text in the app bar.

---

## 4. Tabs in detail

### 4.1 Qibla (`lib/src/ui/qibla_screen.dart`, `lib/src/utils/qibla_utils.dart`)

- `qiblaBearing(lat, lon)` = great-circle initial bearing to the Kaaba
  (`meccaLatitude 21.4225`, `meccaLongitude 39.8262`), normalized to 0–360°.
- Live compass: `FlutterCompass.events` heading + `Geolocator` position; dial
  rotates by `-heading`, needle points at `bearing - heading`.
- Custom `CustomPainter`s: `_DialPainter` (ticks every 2°, majors every 30°),
  `_NeedlePainter` (arrow + "Kaaba" label).
- Static dial fallback when no magnetometer; error state when position
  unavailable. Injectable streams/position loader for tests.

### 4.2 Today (`lib/src/ui/home_screen.dart`)

- 1-second `Timer` drives a live "next prayer" countdown (`formatRemaining`,
  now without leading zeros: `2:03:04`, `0:06` → `6`).
- Header: date, share button (native share sheet with location + date + hijri
  + all six prayer times), refresh button (`refreshPrayerData(forceSync: true)`).
- Location + Hijri date subtitle.
- `_NextPrayerBanner`: "Next: <prayer>" + prayer time pill + "starts in
  <countdown>" using `tabularFigures()` to avoid jitter.
- `_UpcomingRemindersCard`: next 3 enabled calendar reminders; tapping opens
  the Hijri calendar on that date's day-detail sheet.
- Six-prayer list (`_CompactPrayerRow`): next prayer highlighted with
  `primaryContainer`, per-row reminder quick-toggle icon, tap opens
  `ReminderSettingsScreen` for that prayer.
- Empty states: no location (opens Location screen), no prayer data
  (refresh button).

### 4.3 Dates (`lib/src/ui/history_screen.dart`)

Two sub-tabs (TabBar):

- **Prayer Times** — full current-year table: sticky header, per-month
  `DataTable` (zebra rows, today highlighted/bold), columns date (66px) /
  imsak / gunes / ogle / ikindi / aksam / yatsi (44px each) / hijri date
  (108px), synchronized horizontal scrolling, scroll-to-today FAB (estimated
  month offsets + `Scrollable.ensureVisible` refinement).
- **Calendar** — `HijriCalendarView` (see below).

### 4.4 Calendar (`lib/src/calendar/`)

- **`hijri_utils.dart`** — `HijriMonth(year, month)`: `gregorianStart` via
  `hijriToGregorian(y,m,1)`, `daysInMonth`, locale-aware month names (Arabic
  users get native Arabic month names), `shift(delta)` month navigation.
- **`screens/hijri_calendar_screen.dart`** — monthly grid, primary calendar
  switchable (Hijri/Gregorian segmented control), secondary date
  show/hide toggle, today highlight, reminder dots per day (via
  `occursOn`), month navigation stepping in the primary calendar, jump-to-
  today, responsive grid (max 560px wide). `_DayDetailSheet`: previous/next
  day, day's prayer times, day's reminders (enable switch, edit, delete with
  undo — sheet pops first so the SnackBar is reachable), "add reminder"
  pre-filled with the date. `openDetailOnLaunch` opens the sheet directly
  (notification tap path).
- **`models/calendar_reminder.dart`** — `CalendarReminder` with enums
  `ReminderRecurrence {once, daily, weekly, monthly, yearly}`,
  `CalendarBasis {gregorian, hijri}`, `CalendarReminderAnchor {clockTime,
  prayerTime}`. Fields: `anchorAt`, `anchorPrayerName`,
  `anchorOffsetMinutes`, `anchorDate`, `repeatCount` (2–100), `weekdays`,
  `dayOfMonth`, `yearlyDate`, `monthlyBasis`, `yearlyBasis`. Key logic:
  - `occursOn(date)` — calendar day-marker logic, honors `repeatCount` by
    counting real occurrences; legacy prayer-time reminders (null
    `anchorDate`) always occur (old form only made daily prayer-time ones).
  - `nextOccurrenceFrom(from)` — next matching moment (uses `anchorAt`'s
    time-of-day) for "upcoming reminders" surfaces, not scheduling.
  - `toMap/fromMap` — snake_case DB columns; legacy prayer-time → daily
    recurrence migration on load.
- **`screens/calendar_reminder_form_screen.dart`** — anchor
  `SegmentedButton`, date + time pickers, recurrence chips, repeat-count
  chip, Gregorian/Hijri basis chips, weekday chips, day-of-month and yearly
  month/day dropdowns, offset (on-time/before/after, presets
  `[5,10,15,20,30,45,60]` + custom 1–240 min). Prayer anchor resolved at
  save.
- **`screens/calendar_anchor_date_picker.dart`** — modal bottom-sheet date
  picker with primary/secondary calendar display and dual labels.
- **`services/calendar_reminder_service.dart`** — scheduling engine (see
  §7).
- **`services/calendar_midnight_scheduler.dart`** — daily midnight re-arm.

---

## 5. Beads (Tesbihat) module (`lib/src/tesbihat/`)

- **Models**: `Item` (counter: `count`, `check` ≤ half of count, `setCount`,
  `vibrationIntensity` 1–100, `currentProgress`, group membership) and
  `ItemGroup` (container only — counting happens on items). Both implement
  `ReminderSchedulable` (shared 16-field reminder interface). `DailyItemStat`
  for activity stats. Legacy `reminderRepeat` migrates to
  `reminderRecurrence` + bases on load.
- **State (Riverpod)**: `itemsNotifierProvider`, `groupsNotifierProvider`.
  `incrementProgress` returns `TapFeedback {none, standard, checkpoint}`,
  increments `setCount` when progress completes, records daily stats.
  Add/update/delete/restore (undo) for items and groups; reorder items;
  group membership ops.
- **Screens**:
  - `TesbihHomeScreen` — ungrouped items in `ReorderableListView`, horizontal
    group cards, stats card (today / last 7 days / all time), delete-with-undo
    SnackBar (6 s), FAB → new bead / new group bottom sheet.
  - `ExecutionScreen` — big TAP button, progress bar, remaining count,
    checkpoint haptics, wakelock while counting, long-press to edit
    progress/sets, reset with confirmation, notes panel, auto-reset when
    already complete on open.
  - `GroupScreen` — members, add existing beads (multi-select sheet) or
    create a bead inside the group, member popup (edit / remove / delete).
  - `ItemFormScreen` — title, notes, count, check, vibration slider,
    shared `ReminderSection`, group selector chips.
  - `GroupFormScreen` — title + `ReminderSection` only.
- **`widgets/reminder_section.dart`** — shared reminder editor (enable switch,
  anchor chips, recurrence chips, repeat count, basis chips, weekday chips,
  day-of-month/yearly dropdowns, prayer offset with presets + custom).
- **Services**:
  - `ItemReminderService` — tesbih scheduling (see §7).
  - `MidnightReminderScheduler` — daily midnight re-arm, alarm id `5001`.
  - `HapticService` — square-root intensity curve; standard tap duration
    50–1000 ms, checkpoint ×3 (clamped 200–1500 ms), amplitude 30–255 on
    supported devices.
  - `PrayerAnchorResolver` — resolves a prayer-anchored fire time from the
    DB for a given date.

---

## 6. Preferences (`lib/src/ui/preferences_screen.dart`)

Expansion-tile sections:

- **Location** → opens `LocationScreen` (GPS auto-pick or country → state →
  district dropdowns; fuzzy matching with Turkish-diacritic-insensitive
  normalization; save persists and syncs prayer data).
- **Language** — system default + 12 locales (radio list).
- **Theme** — system / light / dark.
- **App-bar remaining placement** — title / trailing chip / subtitle / hidden.
- **Widget text size** — extra small / small / medium / large (pushed to
  native layer).
- **Widget MM:SS threshold** — slider 0–60 minutes (0 = never show MM:SS;
  default 60). See §8.
- **Reminders** — global master switch (silenced), global vibration and sound
  switches.
- **Status-bar minutes** — enables/disables the persistent countdown
  notification.

Per-prayer reminders (`reminder_settings_screen.dart`): on-time toggle,
vibrate/sound overrides, before/after cards with preset minute chips
`[5,10,15,20,30,45,60]` + custom 1–240 minutes, dirty-tracking persisted on
dispose/pause/pop.

---

## 7. Notification system

### 7.1 Prayer reminders (`NotificationService`)

- Channels (one per vibration/sound combo, since Android locks channel
  behavior at first creation): `prayer_reminders_chime_vibrate_sound`,
  `..._vibrate_only`, `..._sound_only`, `..._silent`; all play the bundled
  `reminder_chime.wav`. Stale legacy channels are deleted on init.
- `reschedulePrayerNotifications(...)` — cancels ids 1–48, then schedules
  today+tomorrow × 6 prayers: on-time, before, and after notifications;
  `effectiveVibration = globalVibration && setting.vibrationEnabled`
  (same for sound). Sorted by fire time, truncated to 48.
- **Catch-up**: enabling "before" inside the active pre-prayer window fires a
  "soon" notification at `now + 5s` (only for today's prayers still ahead).
- Scheduling mode: exact-alarm (`exactAllowWhileIdle`) when permission
  granted, otherwise inexact; exceptions fall back to inexact (never silently
  drop).

### 7.2 Calendar reminders (`CalendarReminderService`)

- Channel `calendar_reminders_chime`; ids `700000 + hash % 100000`.
- `_catchUpWindow` 120 min, `_maxOccurrences` 100 (also the id-window size
  per reminder: `base..base+99`).
- Finite `repeatCount` → one-shot per occurrence. Infinite: prayer-anchored →
  single one-shot re-resolved nightly; clock-time recurrence → OS-level
  repeats off-Android, single next-occurrence one-shots on Android (OS
  repeats double-fire there).
- Payload `calendar_reminder:<id>`; body = notes if non-empty else title.

### 7.3 Tesbih reminders (`ItemReminderService`)

- Channel `tesbih_reminders_chime`; ids `800000 + hash % 100000`; payloads
  `tesbih_item:<id>` / `tesbih_group:<id>`.
- Same scheduling matrix as calendar (finite counts, prayer anchor nightly
  re-resolve, Android one-shots).

### 7.4 Midnight background refresh

- `MidnightReminderScheduler` (id `5001`) and `CalendarMidnightScheduler`
  (id `5002`): `AndroidAlarmManager.periodic` at next midnight,
  `exact: true, wakeup: true, rescheduleOnReboot: true`. Entry-point
  callbacks re-schedule all enabled reminders with `catchUp: false` (re-arms
  without re-firing). Each callback initializes the timezone in its own
  isolate (`initializeLocalTimezone()` must run in every isolate that
  schedules).
- `flutter_local_notifications` boot receiver also re-registers scheduled
  alarms on `BOOT_COMPLETED` and `MY_PACKAGE_REPLACED`.

---

## 8. Android home-screen widgets and status-bar notification

### 8.1 The five widgets

| Widget | Provider (Kotlin) | Size | Layout |
|---|---|---|---|
| Next Prayer | `NextPrayerWidgetProvider` | 3×2 | `widget_next_prayer` |
| Remaining Time | `RemainingTimeWidgetProvider` | 2×2 | `widget_remaining_time` |
| Remaining Time Circle | `RemainingTimeCircleWidgetProvider` | 1×1 | `widget_remaining_time_circle` |
| Daily Prayer Times | `DailyPrayerTimesWidgetProvider` | 3×2 | `widget_daily_prayer_times` |
| Upcoming Reminders | `UpcomingRemindersWidgetProvider` | 3×3 | `widget_upcoming_reminders` |

- All widgets: `updatePeriodMillis="0"` (app-driven refresh only, no OS
  polling), `resizeMode="horizontal|vertical"`, API-31+ `previewLayout`.
- Tapping any widget opens the app on the Today tab (`open_home_tab` intent
  extra → `MainActivity` invokes `openHomeTab` channel → controller
  `setTab(1)`).

### 8.2 Data flow (Dart → native)

1. `PrayerAppController` → `WidgetBridgeService.updateFromPrayerDays(...)`
   builds a **timeline** (next prayer epochs from today, +3 days, localized
   names) and **todayPrayers** (today's six epochs) → channel
   `updateWidgetData`.
2. `MainActivity` stores timeline / todayPrayers / locationLabel in
   `PrayerWidgetStorage` (SharedPreferences JSON) and calls
   `PrayerWidgetUpdater.updateAll()` + schedules the alarms.
3. `updateCalendarReminders` pushes the next 3 enabled calendar reminders
   (pre-formatted on the Dart side — native has no l10n access), plus a
   localized header.
4. `updateWidgetTextSize`, `updateWidgetMmssThreshold`, `updateStatusBarConfig`
   update preferences and re-render.

### 8.3 Countdown engine (`PrayerWidgetUpdater.applyCountdown`) — the <60-minute behavior

This is the core of what you asked about. Every countdown surface (Remaining
Time, Circle, Next Prayer) goes through `applyCountdown(views, viewId, next,
now, mmssThresholdMinutes)`:

- **Above the threshold (default: ≥ 60 min remaining)** — static text in
  `H:MM` format, e.g. `4:45` (leading zeros stripped; `0:06` → `6`). Refreshed
  once a minute by an exact alarm (`ACTION_REFRESH_WIDGET_MINUTE`,
  `PrayerWidgetTickReceiver` → `updateAll` → re-`scheduleWidgetMinuteRefresh`,
  PendingIntent id `2004`).
- **Under the threshold (< 60 min remaining)** — switches to a live `M:SS`
  countdown with no leading zeros (`4:32`, `9`), driven by the app once a
  second from `CountdownTickService` (a foreground service): a `Handler`
  re-renders only the three countdown widgets every second via
  `updateCountdownWidgets()` (`applyCountdown` → `formatMinutesSeconds`),
  with no alarms involved in the ticking. The service is started/stopped by
  `scheduleWidgetSecondRefresh` (condition: a countdown widget installed AND
  remaining < threshold; `shouldTickPerSecond`) and reuses the status-bar
  notification (id `710001`) as its foreground notification — a minimal
  "Widget countdown active" one when the status bar is disabled. The
  minute-refresh alarm cancels itself once under the threshold. The platform
  `Chronometer` is deliberately **not** used for widgets: its format always
  zero-pads minutes (`04:32`), and custom view classes in widget layouts are
  rejected by several launchers (Samsung shows "Couldn't add widget" and a
  transparent placeholder). A per-second exact alarm was tried first, but the
  system throttles it to roughly 5-second spacing, which is why the
  foreground service is used instead.
- **At prayer time** — `scheduleNextUpdate` (alarm id `2002`) fires at
  `nextTransition + 1s` (`ACTION_REFRESH_WIDGETS`), which re-renders all
  widgets to the following prayer and re-arms all refreshes.
- Threshold is configurable 0–60 via Preferences ("Widget MM:SS threshold");
  default 60. `0` means the static HH:MM format is always used (and the
  per-second service stays stopped).

### 8.4 Status-bar notification

- Persistent (`setOngoing(true)`, low priority, silent, public visibility),
  channel `prayer_remaining_status`, id `710001`.
- **Collapsed view** (`notification_status_bar.xml`): `<prayer> at <time> ->`
  + a live `Chronometer` `MM:SS` countdown — always live, no threshold logic.
- **Expanded view** (`notification_status_bar_expanded.xml`): all six
  today's prayers as columns (next/current highlighted with a pill), "Time
  Left:" live `Chronometer`, location label.
- **Small icon** (`buildSmallIcon`): under 100 minutes remaining
  (`ICON_DIGIT_THRESHOLD_MINUTES = 100`) draws the minute count as a
  white bitmap (`6`, `59` — no leading zero); otherwise the launcher
  icon. Kept to the minute by exact alarm `ACTION_REFRESH_ICON` (id `2003`),
  which jumps straight to the 100-minute mark rather than ticking through
  hours.
- Dismissible via `StatusBarDismissReceiver` (id `2011`); re-shows on app
  open since `autoRestore = enabled`.

### 8.5 Renderer details

- Text sizes honor the preference (extra small 0.8× / small 0.9× / large
  1.15× scales).
- Circle widget: true square circle drawn as a bitmap (solid teal
  `#FF1F8A70` + translucent white ring), countdown font sized from the
  circle's diameter (`~diameter/3`, 20–36 sp) so up to 5 glyphs (`M:SS` like
  `59:59`) fit inside.
- Daily Prayer Times widget: 6 fixed rows, next prayer row highlighted with
  `widget_row_highlight`; Upcoming Reminders widget: 3 fixed rows or an
  empty-state label.
- All updates happen in `PrayerWidgetUpdater.updateAll`, driven by:
  `updateWidgetData` channel calls, each widget's `onUpdate`/`onEnabled`,
  boot/package-replaced intents, and the alarm actions (`ACTION_REFRESH_WIDGETS`,
  `ACTION_REFRESH_ICON`, `ACTION_REFRESH_WIDGET_MINUTE`). The per-second
  countdown is driven separately by `CountdownTickService` (see §8.3).

---

## 9. Data layer

### 9.1 SQLite (`LocalDatabase`, `prayer_assistant.db` v7)

- `prayer_times` — `district_id`, `date`, `hijri_date`, `imsak`, `gunes`,
  `ogle`, `ikindi`, `aksam`, `yatsi`, `updated_at`; `UNIQUE(district_id, date)`.
- `app_settings` — key/value store with keys: `selected_location`,
  `reminder_settings`, `app_bar_remaining_placement`, `widget_text_size`,
  `widget_mmss_threshold_minutes`, `status_bar_remaining_enabled`,
  `reminders_silenced`, `reminder_vibration_enabled`, `reminder_sound_enabled`,
  `theme_preference`, `locale_preference`, `calendar_primary_display`,
  `show_secondary_calendar_date`.
- `calendar_reminders` — full reminder columns (snake_case), see §4.4.
- Migrations: v2 adds `hijri_date`; v3 ensures reminders table; PRAGMA-based
  repair heals tables missing any newer column on every open (also renames
  the legacy misspelled `calender_reminders` table).
- Key methods: `upsertPrayerDays` (batch replace), `getDay`, `getRange`,
  `hasSufficientYearData` (≥360 days with times AND hijri dates).

### 9.2 Hive (Beads)

- `items_box` — items + groups (list-of-maps JSON); `item_history_box` —
  daily stats (in-memory cache to keep increments fast, persisted lazily).

### 9.3 API (`ImsakiyemApi`)

- Base `https://ezanvakti.imsakiyem.com/api`; endpoints:
  `GET /locations/countries`, `GET /locations/states?countryId=`,
  `GET /locations/districts?stateId=`,
  `GET /prayer-times/{districtId}/yearly?startDate=yyyy-MM-dd`.
- Response envelope `{success, data, message}`; 15 s timeout; friendly
  errors for socket/HTTP/format/timeout/non-200/success=false.

### 9.4 Location resolution

- GPS → geocode to placemark → fuzzy match against API lists with Turkish
  diacritic normalization (`çğışöü` → `cgisou`). Falls back to candidate
  alternates (`'Turkiye'/'Turkey'` etc.). Fails gracefully to manual pick.

---

## 10. Localization

- 12 locales: en, es, fr, de, tr, ur, fa, ar, zh, ja, id, ru (+ system
  default). ARB sources in `lib/l10n/`, generated `AppLocalizations`.
- Separate `TesbihatLocalizations` delegate for the Beads module.
- English and Turkish fully translated; all 11 non-English locales verified
  at 0 missing keys vs the English template.
- Prayer names localized via `prayerNameLabel` (`Imsak/Gunes/Ogle/Ikindi/
  Aksam/Yatsi` map).
- Widget/notification text is pre-localized on the Dart side before crossing
  the channel (native Kotlin has no l10n access).

---

## 11. Tests (`flutter test`)

- **Unit**: time utils, hijri utils, models (prayer, item, group, calendar
  reminder), controller state, items/groups notifiers, local database
  (incl. migrations), item repository, both reminder services (finite
  counts, weekly/monthly/yearly/Hijri variants, catch-up windows, Android
  one-shot behavior, inexact fallback), API parsing.
- **Widget**: app shell, home screen (empty states, refresh, share, reminder
  toggles), history, calendar (grid, basis switch, day detail, delete-undo),
  location, preferences, qibla (bearing math incl. Istanbul & Mecca), reminder
  settings, notification tap routing, tesbih screens, reminder forms.
- **Helpers**: `TestHarness`, mocks for every service, a fake
  `flutter_local_notifications` platform.
- **Golden**: `test/golden/golden_tests_outline.dart` — 9 scenarios,
  skipped by default, baselines not committed.

---

## 12. Known limitations / housekeeping

- Prayer times are always 24-hour format.
- Widgets and the status-bar notification are **Android-only**.
- Midnight reminder refresh is Android-only (iOS refreshes on next app open).
- Exact alarms require user grant on Android 12+.
- `pubspec.yaml` description is still the Flutter placeholder; Android
  package id is still `com.pirci.prayer_assistant`; no store screenshots.
- A live on-device test of an actual calendar-reminder notification firing +
  deep link is still outstanding (blocked by emulator performance; logic is a
  close mirror of the tesbih path which works).

---

## 13. How to see the <60-minute widget behavior yourself

The default MM:SS threshold is 60 minutes, so the live second-by-second
countdown already kicks in whenever the next prayer is under an hour away. To
observe it without waiting:

1. **Install and add widgets**: run the app (or `flutter build apk --debug`),
   long-press the home screen → Widgets → Prayer Assist → add any of
   *Next Prayer*, *Remaining Time*, or *Remaining Time Circle* (these three
   use the countdown; Daily Prayer Times and Upcoming Reminders do not).
2. **Pick a location and sync** the current year's prayer times.
3. **Trick the clock**: set the device time to ~10 minutes before the next
   prayer (Settings → Date & time → set automatically off), then tap the
   refresh icon in the Today tab. The widgets will re-render with a timeline
   based on real prayer epochs; because `now` is only 10 minutes before the
   next prayer, `applyCountdown` immediately switches to the live `M:SS`
   countdown (e.g. `9:59` ticking down every second, no leading zeros).
4. **To compare**: in Preferences → "Widget MM:SS threshold" slide to `0` —
   the widgets then always show the static `H:MM` minute-granularity text
   (e.g. `4:45`), refreshed once a minute; set it to `60` again to restore
   the live mode.
5. **Status-bar notification**: enable "Status-bar minutes" in Preferences;
   its countdown is always live `MM:SS` (platform Chronometer format)
   regardless of the threshold, and under 100 minutes the notification small
   icon shows the minute digits.
