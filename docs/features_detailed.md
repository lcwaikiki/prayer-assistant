# Prayer Assist — Detailed Feature Inventory

Technical feature inventory derived from codebase analysis. All items are factual and current.

## Architecture

- **State management**: Provider (PrayerAppController extends ChangeNotifier) for prayer/calendar/settings; Riverpod for tesbihat state (ItemsNotifier, GroupsNotifier)
- **Local persistence**: SQLite via sqflite (prayer times, calendar reminders, app settings) + Hive via hive_flutter (tesbihat items, groups, daily tap stats)
- **Navigation**: 4-tab bottom nav with lazy IndexedStack: Qibla, Today, Dates, Tesbih
- **Platforms**: Android (full), iOS (core only; no widgets or background midnight refresh)
- **Languages**: 12 UI languages + system default: en, es, fr, de, tr, ur, fa, ar, zh, ja, id, ru
- **Theme**: Light / Dark / System, Material 3, seed color #1F8A70

---

## 1. Prayer Times (Home Tab)

### Daily Prayer Times Display
- Full date (e.g. "Saturday, 22 Aug 2026") and localized Hijri date
- Location label: District, State, Country
- Six prayer times: Imsak, Gunes (Sunrise), Ogle (Dhuhr), Ikindi (Asr), Aksam (Maghrib), Yatsi (Isha) -- 24-hour format
- Live "next prayer" countdown banner updating every 1 second (HH:MM:SS when >1h, MM:SS when <1h)
- Tapping a prayer row opens ReminderSettingsScreen for that prayer
- Today's next prayer row highlighted with primaryContainer

### Data Fetching & Caching
- API: ezanvakti.imsakiyem.com (Diyanet-style) for full year per district
- Cached in SQLite prayer_times table, sufficiency check (>=360 days with hijri dates)
- Offline-first: fully usable without network after first sync
- forceSync flag for manual/force refresh
- Retry mechanism for failed API calls

### Year-Range Data (History Tab -- Prayer Times sub-tab)
- Full-year prayer schedule as a scrollable table
- Columns: Date, Imsak, Gunes, Ogle, Ikindi, Aksam, Yatsi, Hijri
- Sticky header row, synchronized horizontal scrolling
- Today's row highlighted, responsive column sizing
- FAB to jump/scroll to today's row with smooth animation
- Months grouped by name in vertical ListView

### Share Today's Prayer Times
- Generates formatted text block: location, date, hijri date, all 6 prayer times
- Native share sheet via share_plus

### Location Selection
- Cascading dropdowns: Country, State/City, District
- GPS auto-detection via geolocator, reverse geocoding via geocoding, fuzzy matching
- Manual selection via DropdownButtonFormField
- Persisted to SQLite as SelectedLocation

---

## 2. Prayer Reminders

### Per-Prayer Settings (ReminderSettingsScreen)
- On-time reminder toggle
- Before/after prayer toggles with preset minute options (5, 10, 15, 20, 30, 45, 60) and custom (1-240)
- Per-prayer vibration and sound toggles
- Persisted to SQLite app_settings

### Global Switches (Preferences)
- Master reminders silenced toggle (AppBar bell icon)
- Global vibration toggle
- Global sound toggle
- Per-prayer vibration/sound AND-ed with global toggles

### Notification Scheduling
- 48 notification slots (today + tomorrow, 6 prayers x 2 offset types x 2 days)
- Three notification types per prayer: on-time, before, after
- Four Android notification channels for vibration/sound combos, playing reminder_chime
- Exact alarms (exactAllowWhileIdle) with automatic inexact fallback
- Custom vibration pattern: 0.5s vibrate / 1s pause repeating ~10s

---

## 3. Qibla Compass (Qibla Tab)

### Compass Display
- Live magnetometer heading via flutter_compass
- Great-circle bearing to Kaaba (21.4225N, 39.8262E) via qiblaBearing()
- Custom-painted compass dial: tick marks every 2deg, major ticks every 30deg, needle pointer with "Ka" label
- Live mode: dial rotates to keep North up, needle rotates to qibla bearing
- Static fallback: fixed dial when no magnetometer available
- Bearing in degrees, GPS coordinates (lat/lon to 2 decimals), instructional text

### Orientation Lock
- Forces portrait-only on Qibla tab for compass stability

---

## 4. Hijri / Gregorian Calendar (Dates Tab -- Calendar sub-tab)

### Monthly Grid (HijriCalendarView)
- Full 7-column Sunday-first monthly grid
- Toggle primary display: Hijri or Gregorian
- Secondary date: show/hide the other calendar number below primary
- Month navigation (left/right chevrons), jump-to-today
- Today's cell highlighted with primaryContainer
- Reminder dots on days with enabled CalendarReminder
- Responsive grid: max 560dp, cells sized proportionally
- Locale-aware weekday headers and Hijri month titles (12 languages)

### Day Detail Sheet
- Tap a day cell for modal bottom sheet
- Primary and secondary date labels (Gregorian + Hijri)
- Day navigation (left/right arrows)
- That day's prayer times in a card
- That day's calendar reminders: title, recurrence label, enable/disable switch, edit, delete
- Delete with undo snackbar (6s floating)
- Add Reminder button pre-filled with date

### Full-Screen Wrapper (HijriCalendarScreen)
- Pushed from notification taps or upcoming reminders card
- Supports initialDate and openDetailOnLaunch

---

## 5. Calendar Reminders

### Model (CalendarReminder)
- Anchor types: clockTime (fixed date+time) or prayerTime (prayer + offset)
- Recurrence: once, daily, weekly, monthly, yearly
- Monthly/yearly basis: Gregorian or Hijri
- Repeat count: optional finite 2-100 (one-shots) or infinite (recurring)
- Weekday multi-select for weekly recurrence
- Day-of-month dropdown (1-31) for monthly
- Month + day dropdowns for yearly
- Prayer offset: on-time / before / after with preset (5-60 min) or custom minutes
- Enabled/disabled toggle
- anchorDate for recurrence anchoring

### Form (CalendarReminderFormScreen)
- Title and notes fields
- Segmented button: clock time vs prayer time anchor
- Clock-time mode: date picker (calendar grid with Hijri/Gregorian toggle) + time picker
- Prayer-time mode: prayer selection dropdown, offset direction chips, preset/custom minutes
- Recurrence chips (once/daily/weekly/monthly/yearly) for both anchor types
- Repeat count filter chip (2-100)
- Recurrence extras: monthly/yearly basis, weekday multi-select, day-of-month, month+day dropdowns
- Anchor date picker for prayer-time non-daily recurrence
- Edit mode pre-fills all fields

### Scheduling Engine (CalendarReminderService)
- Full recurrence: once, daily, weekly, monthly (Gregorian + Hijri), yearly (Gregorian + Hijri)
- Hijri monthly: computes next Gregorian date for Hijri day-of-month, skipping short months
- Hijri yearly: computes next Gregorian date for Hijri month+day
- Prayer-anchored: resolves concrete fire time from cached SQLite prayer data per occurrence
- Finite repeat: schedules N one-shot notifications (IDs base..base+N-1)
- Android: avoids OS-level repeats (known double-fire bug), uses one-shot + midnight re-arm
- iOS: uses native matchDateTimeComponents repeats
- Notification ID range: 700000-799999

### Midnight Scheduler (CalendarMidnightScheduler)
- Android-only: android_alarm_manager_plus periodic alarm at midnight
- Re-reads all reminders from SQLite, re-schedules each (catchUp: false)
- rescheduleOnReboot: true, exact: true, wakeup: true
- iOS: refresh on next app open

### Upcoming Reminders on Home Screen
- Shows 3 soonest enabled calendar reminders
- Each: icon, title, formatted date+time
- Tapping navigates to HijriCalendarScreen with detail open

### Notification Tap Handling
- Payload prefix: calendar_reminder:REMINDER_ID
- Tapping opens HijriCalendarScreen at today with detail open
- Cold-start handled via handleAppLaunchFromNotification

---

## 6. Beads / Tesbihat (Tesbih Tab)

### Home Screen (TesbihHomeScreen)

#### Stats Card
- 3 tiles: Today's taps, Last 7 days' taps, All-time total taps
- Aggregated from DailyItemStat history (Hive-backed)

#### Groups
- Horizontal scrollable group cards (140dp x 92dp)
- Each: title, member count, reminder bell or folder icon
- Tapping opens GroupScreen

#### Ungrouped Beads
- Vertical ReorderableListView with drag handles
- Each card: title, count/check/sets info, progress fraction, reminder bell, popup menu (edit/delete)
- Delete with undo (6s floating snackbar, restores at original index)
- Tapping opens ExecutionScreen

#### Add Menu
- FAB opens bottom sheet: "New Bead" and "New Group"

### Bead Model (Item)
- id (timestamp-based), title, notes
- count (target total), check (checkpoint interval)
- setCount (auto-increments when count reached), vibrationIntensity (1-100)
- currentProgress (0 to count), groupIds (multi-membership)
- Full reminder fields (same as calendar reminders): enabled, anchor clockTime/prayerTime, recurrence, monthlyBasis/yearlyBasis, reminderAt, anchorDate, prayerName, offsetMinutes, repeatCount, weekdays, dayOfMonth, yearlyDate

### Bead Form (ItemFormScreen)
- Title (required), notes (3-6 lines with hint)
- Count field (digits only, >0)
- Check interval (digits only, >0, <= count/2)
- Set count (read-only display)
- Vibration intensity slider (1-100)
- Full ReminderSection widget (shared with group form)
- Group selector: FilterChip multi-select for existing groups
- Validation: title required, count positive, check half-error rule

### Execution Screen (ExecutionScreen)
- Keep-awake via WakelockPlus while counting (enabled on enter, disabled on exit)
- Auto-reset: if progress already equals count on open, resets to 0
- Stats row: Count (target), Remaining (count-progress), SetCount (completed sets)
- Linear progress bar across full width
- Large progress number, long-press opens edit dialog
- Full-screen tap button (48pt bold), disabled when progress reaches count
- Reset button with confirmation dialog
- Edit dialog: adjust current progress (0..count) and set count (>=0) with validation
- Notes panel (140dp tall scrollable container)

### Haptic Feedback (HapticService)
- Uses vibration package with amplitude control
- Standard tap: single vibration, 50-1000ms mapped from intensity (sqrt curve)
- Checkpoint tap: triple duration (200-1500ms)
- Amplitude control: 1-100 intensity mapped to 30-255 amplitude with sqrt curve
- Falls back to duration-only on devices without amplitude control
- Checks Vibration.hasVibrator() before vibrating

### Bead State (ItemsNotifier, Riverpod)
- CRUD: addItem, updateItem, deleteItem, restoreItem (undo with index insertion)
- Reorder: reorderItems for drag-and-drop
- Progress: incrementProgress (+1, auto-increments setCount when count reached, records daily stat)
- Reset/SET: resetProgress, updateProgressAndSetCount with validation
- Group membership: removeGroupFromItems (bulk cleanup), addItemsToGroup, removeItemFromGroup
- All mutations save to Hive via ItemRepository and schedule/cancel reminders via ItemReminderService
- Returns TapFeedback enum: none/standard/checkpoint for haptic feedback routing

### Groups (ItemGroup)
- Container model: id, title, full reminder fields (same as Item)
- No counter of its own; organizes beads
- A bead can belong to multiple groups (multi-membership)
- Groups have their own independent reminders

### Group Screen (GroupScreen)
- Shows all member beads as ListView of Cards
- Each: title, count/check/sets/progress, reminder bell, popup menu (edit/remove from group/delete)
- Delete with confirmation dialog, also removes group membership from all member beads
- FAB opens bottom sheet: "Add Existing Beads" (multi-select checkboxes) and "New Bead" (pre-selects group)
- AppBar actions: edit group (GroupFormScreen), delete group

### Group Form (GroupFormScreen)
- Title field (required)
- Full ReminderSection identical to bead form

### Bead & Group Reminder Scheduling (ItemReminderService)
- Mirrors CalendarReminderService in structure and recurrence logic
- Separate notification channel: tesbih_reminders_chime
- Notification ID range: 800000-899999 (hash-based from item/group ID)
- Payload prefixes: tesbih_item:ITEM_ID and tesbih_group:GROUP_ID
- Tapping item notification opens ExecutionScreen
- Tapping group notification opens GroupScreen
- Finite repeat count schedules N one-shot notifications
- Hijri monthly/yearly recurrence supported (same algorithms as calendar)
- Cancels full 100-slot per-occurrence window on re-schedule

### Midnight Scheduler for Tesbihat (MidnightReminderScheduler)
- Mirror of CalendarMidnightScheduler for bead/group reminders
- Android-only, uses android_alarm_manager_plus with alarm ID 5001
- Re-reads items and groups from Hive, re-schedules each (catchUp: false)

---

## 7. Android Home-Screen Widgets

### Widget Bridge (WidgetBridgeService)
- MethodChannel: prayer_assistant/widget
- Pushes prayer times widget data: upcoming timeline + today's all 6 prayers
- Pushes calendar reminders widget data: up to 3 upcoming enabled reminders
- Updates on locale change, data refresh, and app init
- Widget text size config: extraSmall/small/medium/large
- MM:SS threshold config: 0-60 minutes, below which widgets count down in MM:SS
- Status bar config: enabled/autoRestore for persistent remaining-time notification
- Home tab handler: replay any pending open-home requests from cold start

### 5 Widget Types
- Next Prayer (3x2)
- Remaining Time (2x2)
- Remaining Time Circle (1x1 circular countdown)
- Daily Prayer Times (3x2)
- Upcoming Reminders (3x3)

### Widget Preferences (in-App)
- Widget text size: Extra Small / Small / Medium / Large radio buttons
- MM:SS countdown threshold: slider 0-60 minutes (default 60)

---

## 8. Settings / Preferences

### Location Display
- Shows current location name, tapping opens LocationScreen

### Language
- 12 languages + Follow System radio buttons
- AppLocalePreference enum persisted to SQLite

### Theme Mode
- System / Light / Dark radio buttons
- Quick toggle from AppBar bell icon (cycles light/dark)

### AppBar Remaining Time Placement
- Title / Trailing (chip) / Subtitle / Hidden
- Controls where minutes-remaining-to-next-prayer displays

### Widget Text Size
- Extra Small / Small / Medium / Large radio buttons

### Widget MM:SS Countdown Threshold
- Slider 0-60 minutes

### Reminders Switches
- Master reminders toggle (SwitchListTile)
- Vibration enabled toggle
- Sound enabled toggle

### Status Bar Remaining Time
- Toggle for persistent notification showing min until next prayer (Android only)

---

## 9. Notification Infrastructure

### NotificationService
- flutter_local_notifications with exact alarm support on Android
- Permission requests for notifications and exact alarms
- Four permanent channels for per-prayer vibration/sound combos
- Stale legacy channel cleanup on init
- cancelAllPrayerNotifications() clears IDs 1-48
- getPendingScheduledReminders() returns pending notifications
- showTestNotificationNow() for diagnostic testing

### Notification Tap Handler
- Unified router for all notification taps (shared platform channel)
- Payload prefix-based dispatch
- calendar_reminder: -> HijriCalendarScreen
- tesbih_item: -> ExecutionScreen
- tesbih_group: -> GroupScreen
- handleAppLaunchFromNotification() for cold-start notification taps

### Timezone
- timezone_setup.dart initializes local timezone via flutter_timezone

---

## 10. Services

| Service | Purpose |
|---|---|
| ImsakiyemApi | Fetches location lists and yearly prayer times from ezanvakti.imsakiyem.com |
| LocalDatabase | SQLite: prayer_times, app_settings, calendar_reminders tables (DB v7) |
| LocationResolver | GPS + reverse geocoding + fuzzy matching against API location nodes |
| NotificationService | Prayer notification scheduling (on-time/before/after with vibration/sound) |
| CalendarReminderService | Calendar reminder scheduling with full recurrence engine |
| CalendarMidnightScheduler | Android nightly re-arm of calendar reminders |
| ItemReminderService | Bead/group reminder scheduling (same recurrence engine) |
| MidnightReminderScheduler | Android nightly re-arm of tesbihat reminders |
| WidgetBridgeService | MethodChannel bridge to Android home-screen widgets |
| HapticService | Vibration feedback for bead counter (amplitude-controlled) |
| prayer_anchor_resolver | Resolves prayer-anchored fire times from cached prayer data |

---

## 11. General UX

- Loading states: CircularProgressIndicator on init, busy states disable action buttons
- Error handling: errors surfaced via SnackBar (shown once per distinct error)
- Empty states: dedicated placeholders with icon, title, subtitle, action button
- PopScope: location screen auto-pops back on successful save
- Reboot resilience: midnight schedulers use rescheduleOnReboot: true
- Material 3: useMaterial3: true, CardThemeData(elevation: 0)
- App icon: flutter_launcher_icons with adaptive icon (green #1F8A70 background)

## 12. Dependencies

| Package | Purpose |
|---|---|
| provider (v6) | ChangeNotifier state management for prayer/settings |
| flutter_riverpod (v2) | NotifierProvider for tesbihat state |
| sqflite | SQLite local database |
| hive + hive_flutter | Hive key-value store for tesbihat data |
| hijri (v3) | Hijri calendar conversions + localized month names |
| intl (v0.20) | Date/time formatting and localization |
| flutter_local_notifications (v22) | Scheduled notifications |
| timezone + flutter_timezone | Timezone-aware scheduling |
| android_alarm_manager_plus | Midnight background alarm jobs |
| geolocator (v14) | Device GPS position |
| geocoding (v5) | Reverse geocoding |
| http | API calls |
| flutter_compass (v0.8) | Device magnetometer for qibla |
| vibration (v3) | Haptic feedback for bead counter |
| wakelock_plus (v1) | Keep screen awake during bead counting |
| share_plus (v13) | Native share sheet for prayer times |
