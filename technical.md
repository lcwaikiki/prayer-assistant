# Prayer Assist — Technical Documentation

Technical reference for engineers working on the **Prayer Assist** codebase.
All facts below are derived from the current source (September 2026). This is
the authoritative technical doc; older files (`content.md`, `features.md`,
`features_detailed.md`) are superseded where they conflict.

---

## 1. Project overview

| | |
|---|---|
| **Name** | Prayer Assist (`prayer_assistant`) |
| **Type** | Flutter mobile app — Islamic daily-practice assistant |
| **Version** | 1.0.0+1 |
| **Dart SDK** | `^3.12.2` |
| **UI** | Material 3, seed color `#1F8A70` |
| **Target platforms** | Android (full feature set), iOS (core features) |
| **Codebase size** | 84 Dart files in `lib/` (~37,900 LOC), ~3,100 LOC native Kotlin, 53 test files (~10,800 LOC) |
| **Git** | 128 commits, single-branch (`master`) development |

### What the app does

- **Prayer times** — six daily prayer times per location from a Diyanet-style
  API, cached offline for a full year.
- **Reminders** — per-prayer on-time / before / after notifications with
  vibration/sound/adhan options; calendar reminders with full recurrence;
  beads (dhikr) reminders.
- **Calendar** — Hijri + Gregorian monthly grids, Islamic holidays, moon
  phase, fasting badges, offline Hijri↔Gregorian conversion.
- **Tracking** — completed/missed prayer log, streaks & analytics, Kaza
  (missed-prayer) counter, fasting (Ramadan/Sunnah/Qadaa) log.
- **Content** — daily wisdom (Ayah/Hadith) and a Hisn al-Muslim supplications
  library with counters.
- **Beads (Tesbih)** — digital dhikr counters with groups, haptics, reminders.
- **Qibla** — live compass toward the Kaaba.
- **Android extras** — 8 home-screen widgets and a status-bar countdown
  notification, backed by native Kotlin.

---

## 2. Architecture

### 2.1 Layering

```
lib/
  main.dart                          App entry: init storage/services, runApp
  src/
    controller/prayer_app_controller.dart   Main ChangeNotifier state (source of truth)
    models/                          PrayerDay, ReminderSetting, settings enums,
                                     FastingLog, CalendarWeekStart
    services/                        API client, SQLite, GPS resolver, notifications,
                                     widgets bridge, analytics, backup/export
    calendar/                        Hijri/moon-phase utils, calendar reminders,
                                     calendar UI + midnight scheduler
    kaza/                            Missed-prayer tracker (model, screens, widgets)
    tesbihat/                        Beads module: models, Hive repo, Riverpod state,
                                     reminder service, screens
    supplications/                   Daily wisdom + supplications (models, service, UI)
    ui/                              AppShell + top-level screens
    l10n/                            Locale options, prayer-name labels
    utils/                           Prayer order, time parsing
  l10n/                              Generated localizations + *.arb sources
android/app/src/main/kotlin/...      Native: widgets, countdown tick service, storage
```

### 2.2 State management — two frameworks, by design

| Area | Framework | Entry point |
|---|---|---|
| Location, prayer data, preferences, calendar reminders, tracking | `provider` + `ChangeNotifier` | `PrayerAppController` |
| Beads items, groups, per-item stats | `flutter_riverpod` | `ItemsNotifier` / `GroupsNotifier` (`NotifierProvider`) |

`PrayerAppController` (`lib/src/controller/prayer_app_controller.dart`) is the
app's single source of truth for: selected location, today's `PrayerDay`, the
full-year `_yearRange`, per-prayer `ReminderSetting`, app-bar countdown
placement, widget preferences (text size, theme, calendar display, MM:SS
threshold), theme/locale, reminder toggles, prayer-completion history, Kaza
tracker, fasting logs, and calendar reminders. Every setter persists to SQLite
and calls `notifyListeners()`.

### 2.3 Storage

| Store | Tech | Contents |
|---|---|---|
| SQLite (`prayer_assistant.db`, **schema v7**) | `sqflite` via `LocalDatabase` | `prayer_times` (per-day 6 times + Hijri date, keyed by district), `app_settings` (all scalar prefs, completions, Kaza, fasting logs), `calendar_reminders` |
| Hive boxes | `hive_flutter` | `items_box` (beads + groups), `item_history_box` (daily tap stats) |
| Assets | bundled JSON | `assets/data/daily_wisdom.json`, `assets/data/supplications.json` |
| SharedPreferences | native (Kotlin) | Widget data (`PrayerWidgetStorage`) |

Offline-first: the full-year prayer schedule is cached per district; a
sufficiency check (≥360 days) avoids refetching. Everything except the initial
location sync works without network.

### 2.4 Networking

- `ImsakiyemApi` (`lib/src/services/imsakiyem_api.dart`) — `http` client for
  `https://ezanvakti.imsakiyem.com/api` (Diyanet-style): countries →
  states → districts, and yearly prayer times per district.
- `LocationResolver` — `geolocator` GPS + `geocoding` reverse geocode, fuzzy
  matching against the API location lists.
- Failure mode: errors surface as a SnackBar on the Location screen;
  `refreshPrayerData(forceSync:)` retries; cached data keeps the app usable.

### 2.5 Notifications — three independent producers

| Producer | Notification ID range | Purpose |
|---|---|---|
| `NotificationService` | 1–48 (+ test 900001) | Prayer reminders (on-time/before/after per prayer, 2-day horizon) |
| `CalendarReminderService` | 700000–799999 | Calendar reminders (full recurrence engine) |
| `ItemReminderService` | 800000–899999 | Beads/group reminders |

- **Channels**: four per-prayer vibration/sound combos + two adhan channels
  (`prayer_reminders_adhan_vibrate_sound`, `prayer_reminders_adhan_sound_only`,
  sound resource `res/raw/adhan.wav`). Stale legacy channels are cleaned up on
  init.
- **Tap routing**: all payloads funnel through `handleNotificationTap(payload)`
  (`notification_tap_handler.dart`) and dispatch on prefixes
  `calendar_reminder:`, `tesbih_item:`, `tesbih_group:` via
  `rootNavigatorKey`. Cold-start taps are handled after the first frame.
- **Timezone**: `timezone_setup.dart` initializes the local timezone via
  `flutter_timezone`.

### 2.6 Background refresh (Android)

| Job | Alarm ID | Work |
|---|---|---|
| `MidnightReminderScheduler` | 5001 | Re-resolves tesbih prayer-anchored + Hijri-basis reminders at midnight |
| `CalendarMidnightScheduler` | 5002 | Same for calendar reminders |

Both use `android_alarm_manager_plus` (periodic, `rescheduleOnReboot: true`,
`exact: true`, `wakeup: true`). The OS cannot natively repeat floating prayer
times or Hijri dates, so the app schedules one-shot notifications and re-arms
them nightly. iOS has no equivalent — these refresh on next app open.

### 2.7 Recurrence engine (shared logic)

`CalendarReminderService` and `ItemReminderService` mirror each other:

- Anchors: fixed **clock time** or **prayer time** (+ before/on-time/after
  offset, presets 5–60 min or custom 1–240).
- Recurrence: once / daily / weekly (multi-select weekdays) / monthly /
  yearly — monthly & yearly on **Gregorian or true Hijri** basis (Hijri
  anniversaries drift ~11 days/year earlier in Gregorian).
- Finite repeat count (2–100) → N one-shot notifications.
- Android: avoids OS-level repeats (double-fire bug) — one-shot + midnight
  re-arm. iOS: native `matchDateTimeComponents` repeats.
- Prayer-anchored fire times resolve from the SQLite prayer cache per
  occurrence (`resolvePrayerAnchoredTime`).

### 2.8 Android home-screen widgets (native Kotlin)

Method channel `prayer_assistant/widget` (`WidgetBridgeService`) pushes data to
`PrayerWidgetUpdater` / `PrayerWidgetStorage` (SharedPreferences). **Eight
widgets**, registered in `AndroidManifest.xml`:

| Widget | Class |
|---|---|
| Next Prayer (3×2) | `NextPrayerWidgetProvider` |
| Remaining Time (2×2) | `RemainingTimeWidgetProvider` |
| Remaining Time Circle (1×1) | `RemainingTimeCircleWidgetProvider` |
| Daily Prayer Times (3×2) | `DailyPrayerTimesWidgetProvider` |
| Upcoming Reminders (3×3) | `UpcomingRemindersWidgetProvider` |
| Fasting Countdown (Iftar/Suhoor) | `FastingCountdownWidgetProvider` |
| Calendar | `CalendarWidgetProvider` |
| Moon Phase | `MoonPhaseWidgetProvider` |

Supporting native code: `CountdownTickService`, `PrayerWidgetTickReceiver`,
`StatusBarDismissReceiver`, `WidgetConfigActivity` (native widget-settings
dialog, kept in sync with the Flutter Preferences screen).

Widget preferences (text size, theme, Hijri/Gregorian display, MM:SS
threshold) are stored in SQLite on the Flutter side and mirrored to native.

### 2.9 Localization

- `flutter gen-l10n` (`AppLocalizations`), 12 locales + "follow system":
  en, tr, es, fr, de, ur, fa, ar, zh, ja, id, ru.
- Separate `TesbihatLocalizations` delegate for the Beads module.
- All 11 non-English locales have 0 missing keys vs. the English template.
- Hijri month names: custom locale maps registered for languages the `hijri`
  package doesn't natively support (`hijri_utils.dart`); Arabic numerals for
  `ar`.
- Widget/notification text is pre-formatted on the Dart side (native layer has
  no l10n access).

---

## 3. Feature modules

### 3.1 Today tab (`ui/home_screen.dart`)
Edge-to-edge layout; today's six prayer times (Imsak, Güneş, Öğle, İkindi,
Akşam, Yatsı — 24h), live countdown to next prayer (1s tick), tap a row →
`ReminderSettingsScreen` (on-time/before/after, presets + custom minutes,
per-prayer vibration/sound/adhan). Dashboard cards (moon phase, iftar/suhoor
countdown, daily wisdom, upcoming reminders) are individually toggleable via
Preferences. Prayer-completion toggling is date-safe across midnight rollover.

### 3.2 Dates tab (`ui/history_screen.dart`) — three sub-tabs
1. **Prayer Times** — full-year table (6 times + Hijri date), sticky header,
   today highlight, scroll-to-today FAB; share today's times via native share
   sheet.
2. **Calendar** — monthly grid, switchable primary Hijri/Gregorian, secondary
   date show/hide, week-start Monday/Sunday, day-offset setting (for
   sighting-based Hijri correction), holiday highlighting (10 Islamic
   holidays), fasting badges, reminder dots, day-detail bottom sheet with
   per-day prayer times and reminder CRUD (delete with undo).
3. **Moon calendar** — moon-phase visualization (astronomical synodic-month
   calculation) with White Days (13–15 Hijri) fasting integration.

### 3.3 Track tab (`kaza/`) — Kaza (Qadaa) tracker
Counters for Fajr, Dhuhr, Asr, Maghrib, Isha, Witr: target vs. completed,
increment/decrement, daily pace (default 6/day), estimated completion date.

### 3.4 Analytics (`ui/analytics_dashboard_screen.dart` + `services/prayer_analytics_service.dart`)
- Current & longest streak (full: all 5 core prayers; active: ≥1 prayer).
- Monthly completion heatmap grid.
- Per-prayer completion-rate breakdown + overall rate, total prayers logged.

### 3.5 Qibla tab (`ui/qibla_screen.dart`)
Live compass via `flutter_compass`, great-circle bearing to Kaaba
(21.4225N, 39.8262E), custom-painted dial, static fallback without a
magnetometer. Portrait-only lock on this tab. Injectable `qiblaScreen` widget
for testability.

### 3.6 Tesbih tab (`tesbihat/`)
- Beads: count, checkpoint interval, vibration intensity (1–100 → amplitude
  30–255 with sqrt curve), notes, reorder, edit/delete with undo, daily
  activity stats (today / 7 days / all-time from Hive `item_history_box`).
- Execution screen: wakelock while counting, progress bar, long-press edit,
  reset, notes panel.
- Groups: one-level containers, multi-membership, own reminders.
- Reminders identical to calendar reminders (shared `ReminderRecurrence` /
  `CalendarBasis` enums). Tapping a notification deep-links to the counter /
  group screen.

### 3.7 Fasting (`ui/fasting_screen.dart`, `ui/widgets/iftar_suhoor_countdown_card.dart`)
- Iftar & Suhoor countdown timers (dynamic daily target from prayer data).
- Fasting log: Ramadan / Sunnah / Qadaa per day, with Sunnah day detection
  (Monday/Thursday, White Days, Ashura, Arafah) via `SunnahDayInfo.checkDate`.
- Notifications for Monday/Thursday & White Days.

### 3.8 Supplications (`supplications/`)
- Daily rotating Ayah/Hadith card (deterministic date-based selection),
  Arabic + transliteration + multi-language translations, share.
- Hisn al-Muslim library: 5 categories (morning, evening, after prayer,
  sleeping, daily life), search, built-in counters.

### 3.9 Backup & export (`services/backup_export_service.dart`)
- Full JSON backup/restore: Kaza tracker, prayer completions, calendar
  reminders, tesbih items/groups/stats, fasting logs, preferences (versioned
  payload, validated on restore).
- iCalendar (.ics) export of the 10 Islamic holidays for the current year.

---

## 4. Testing

```
test/
  unit/        calendar, models, services, state, utils (incl. recurrence engine)
  widget/      20 screen-level widget tests
  golden/      golden_toolkit snapshots
  helpers/     mocks (mocktail), test_app harness, sqflite_common_ffi in-memory DB
integration_test/app_smoke_test.dart   End-to-end smoke
```

Run everything:

```sh
flutter test
```

Current static-analysis status: `flutter analyze` → **0 errors**, 19 warnings,
100 infos (mostly unused-import / style infos).

---

## 5. Build & run

```sh
flutter pub get
flutter gen-l10n        # regenerate localizations after .arb changes
flutter run

# Release APK (includes native widgets/Kotlin)
flutter build apk --release
```

Platform scaffolding exists for android, ios, linux, macos, web, windows;
the product surface is Android + iOS.

---

## 6. Known issues & housekeeping

- **Outdated docs**: `README.md`, `features.md`, `features_detailed.md`,
  `content.md`, `plan.md` predate several modules (Kaza, fasting, analytics,
  supplications, backup/export, moon calendar, 3 new widgets). This file is
  current.
- **pubspec metadata**: `description` is still the Flutter placeholder
  ("A new Flutter project."); Android package id is
  `com.pirci.prayer_assistant` — change to a real reverse-domain id before
  release.
- **Open verification**: calendar-reminder notification firing + tap-to-open
  deep link was not confirmed on a physical device (emulator ANR blocked the
  check); logic mirrors the already-working tesbih path.
- **Store assets**: no app-store screenshots or feature graphic yet.
- **Dual state frameworks** (provider + Riverpod) is intentional but a
  long-term consolidation candidate.
- **iOS parity**: no home-screen widgets, no status-bar countdown, and
  midnight re-arm happens on next app open (no background-alarm equivalent).

---

## 7. Key architectural invariants (don't break these)

1. Notification ID ranges are **non-colliding and reserved**: prayer 1–48,
   calendar 700000–799999, tesbih 800000–899999, test 900001.
2. Prayer-anchored and Hijri-basis reminders must be **one-shot + midnight
   re-arm** on Android (never OS-level repeats).
3. `PrayerAppController` persists before/after notifying; UI updates are
   synchronous with persistence (`notifyListeners()` immediately after
   in-memory change, before awaiting DB/notification writes).
4. Widget text is localized **on the Dart side** before crossing the method
   channel.
5. All user-data mutations (reminders, beads, completions, logs) must flow
   through the backup/restore payload to stay exportable.
6. SQLite schema is versioned (`v7`) — bump and migrate, never mutate in place.