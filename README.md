# Prayer Assist

A Flutter mobile app for Islamic daily practice: prayer times, Hijri/Gregorian
calendar with reminders, and a digital dhikr (tesbih) counter with reminder
support. Data comes from a Diyanet-style prayer-times API; reminders and the
calendar work fully offline after the yearly schedule is cached.

## Features

- **Location** — auto-detect your location via GPS, or pick it manually from
  the Country → State → District picker. Backed by the
  `ezanvakti.imsakiyem.com` API.
- **Today** — today's six prayer times (Imsak, Güneş, Öğle, İkindi, Akşam,
  Yatsı), the upcoming prayer highlighted with a live countdown, and an
  "Upcoming reminders" card. Tap any prayer for per-prayer reminder settings
  (on-time / before with preset or custom minutes, per-prayer vibration and
  sound overrides).
- **Dates**
  - *Prayer Times* — full current-year table (per-day prayer times + Hijri
    date), scroll-to-today button.
  - *Calendar* — monthly Hijri/Gregorian grid (either calendar can be primary,
    the secondary can be hidden), today highlight, and reminder dots per day.
    Tapping a day opens a sheet to manage that day's reminders. Reminders can
    be anchored to a calendar date/time or a prayer time, with once / daily /
    weekly / monthly / yearly recurrence; yearly and monthly can follow the
    Gregorian or the true Hijri date.
- **Beads (Tesbih)** — dhikr counters with count, checkpoint interval,
  vibration intensity, notes, reorder, edit/delete with undo. Optional
  once/daily or prayer-anchored reminders; tapping a reminder notification
  opens that item's counter screen.
- **Preferences** — language, theme mode, app-bar countdown placement, widget
  text size, and global reminder/vibration/sound toggles.
- **Home-screen widgets (Android)** — Next Prayer, Remaining Time, and
  Upcoming Reminders widgets, kept in sync with the app over a method channel.

## Tech stack

- **State**: `PrayerAppController` (`provider` `ChangeNotifier`) for the main
  app; `ItemsNotifier` (`flutter_riverpod`) for the Beads module.
- **Storage**: `sqflite` (`LocalDatabase`) for the prayer-times cache, app
  settings, and calendar reminders; Hive (`ItemRepository`) for Beads items.
- **Notifications**: `flutter_local_notifications` with three non-colliding id
  ranges — prayer (1–48), calendar (700000–799999), tesbih (800000–899999).
- **Background refresh (Android)**: `AndroidAlarmManager` daily midnight jobs
  re-resolve prayer-anchored and Hijri-basis reminders (`MidnightReminderScheduler`
  id 5001, `CalendarMidnightScheduler` id 5002). iOS has no equivalent, so
  these refresh on next app open.
- **Networking**: `http` client (`ImsakiyemApi`), `geolocator` + `geocoding`
  for GPS auto-pick.
- **Localization**: `flutter gen-l10n` — 11 locales (en, tr, es, fr, de, ur,
  fa, ar, zh, ja, id) plus a separate `TesbihatLocalizations` delegate.

## Project layout

```
lib/
  main.dart                  App entry: init storage, services, runApp
  src/
    controller/prayer_app_controller.dart   Main ChangeNotifier state
    models/prayer_models.dart               Location, PrayerDay, settings
    services/
      imsakiyem_api.dart     Diyanet-style prayer-times API client
      local_database.dart    sqflite schema, settings, prayer cache
      location_resolver.dart GPS → country/state/district matching
      notification_service.dart  Prayer reminder scheduling
      widget_bridge_service.dart  Method channel to Android widgets
    ui/                      AppShell + tab screens (Today, Dates, etc.)
    calendar/                Hijri/Gregorian calendar, reminders, midnight job
    tesbihat/                Beads module: models, Hive repo, screens, services
    l10n/                    Locale options, prayer name labels
    utils/                   Prayer order/time parsing helpers
  l10n/                      Generated localizations + *.arb sources
```

## Getting started

Requires Flutter (SDK `^3.12.2`).

```sh
flutter pub get
flutter gen-l10n
flutter run
```

Build a release APK:

```sh
flutter build apk --release
```

## Tests

```sh
flutter test
```

## Troubleshooting

**"Could not reach prayer server / Request failed / timed out" errors**
(sometimes reported as "endpoint unavailable"): the app can't reach
`https://ezanvakti.imsakiyem.com/api`, or the server returned a non-200 or
error payload. This is a network/server-side issue — check internet
connectivity, DNS, and that the API is up:

```sh
# quick endpoint health check
curl "https://ezanvakti.imsakiyem.com/api/locations/countries"
```

Errors thrown by `ImsakiyemApi._get` (lib/src/services/imsakiyem_api.dart) are
surfaced as a SnackBar on the Location screen. A refresh (`refreshPrayerData`)
retries; already-cached yearly data keeps the app usable offline. Note the
endpoint also returns `success: true` with an empty `data` array for an
unknown district id — double-check the district selection if prayer times load
as blank.

## See also

- [`plan.md`](plan.md) — living feature inventory and todo checklist.
