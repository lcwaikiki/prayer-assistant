# Notification Snooze & Action Buttons Feature

## Overview
Implements snoozable, non-dismissible notifications for prayer reminders, calendar reminders, and tesbihat items. Notifications provide three action buttons (Snooze, Dismiss, Done) and automatically reopen if swiped away from the system shade, ensuring reminders cannot be accidentally dismissed.

---

## Key Capabilities

1. **Configurable Snooze Duration**:
   - Configurable in **Preferences** under the Reminders section.
   - Options: 5 min, 10 min, 15 min, 20 min (default: 10 min).
   - Persisted in local database (`snooze_duration_minutes`) and synced to native preferences (`PrayerWidgetStorage`).

2. **Action Buttons**:
   - **Snooze**: Cancels the current notification and schedules a re-alert after the configured snooze duration (handled natively via `ReminderActionReceiver` in <5ms without requiring background Flutter engine).
   - **Dismiss**: Cancels and closes the notification without rescheduling.
   - **Done**: Marks the item/prayer as completed in the database and closes the notification (e.g. "Yapıldı" in Turkish).
   - Localized across all 14 supported languages in the application.

3. **Re-open on Swipe (Android `deleteIntent`)**:
   - Notifications are marked ongoing (`setOngoing(true)`).
   - If a user swipes or clears the notification on Android, an attached `deleteIntent` triggers `ReminderDismissReceiver`, which immediately re-displays the notification.
   - Only tapping an explicit action button (Snooze, Dismiss, Done) programmatically cancels the notification and marks the action handled so it won't be re-opened.

---

## Architecture & Implementation

### 1. Native Android Engine
- **`ReminderNotificationManager.kt`**:
  - Builds `NotificationCompat` with `deleteIntent`, ongoing flag, high priority, vibration pattern, sound, and action buttons targeting `ReminderActionReceiver`.
  - Schedules alarms via `AlarmManager.setExactAndAllowWhileIdle`.
  - Uses deterministic request codes (`id * 10 + offset`) to prevent PendingIntent collision.
  - Tracks handled actions via `markActionHandled` / `isActionRecentlyHandled` to prevent swipe re-open on explicit button taps.
- **`ReminderActionReceiver.kt`**:
  - Natively receives notification action clicks (`action_snooze`, `action_dismiss`, `action_done`).
  - For Snooze: Cancels notification, reads snooze minutes from `PrayerWidgetStorage`, and immediately schedules exact alarm via `AlarmManager.setExactAndAllowWhileIdle`. Runs independently of Flutter runtime.
  - For Dismiss: Cancels notification and any pending reminder alarm.
  - For Done: Cancels notification and forwards intent to `ActionBroadcastReceiver` so Flutter records prayer completion in database.
- **`ReminderDismissReceiver.kt`**:
  - Catches OS notification dismissal (`deleteIntent`) and immediately re-invokes `ReminderNotificationManager.show()` if the notification was dismissed by user swipe rather than an action button.
- **`ReminderAlarmReceiver.kt`**:
  - Catches `AlarmManager` triggers and displays the reminder notification.
- **`MainActivity.kt`**:
  - Registers `prayer_assistant/native_reminders` MethodChannel handling `show`, `schedule`, and `cancel`.
  - Syncs `snoozeDurationMinutes` via `prayer_assistant/widget` channel.

### 2. Dart & Flutter Layer
- **`NativeReminderService` (`lib/src/services/native_reminder_service.dart`)**:
  - MethodChannel client interfacing Flutter with native Android reminder managers.
- **`NotificationTapHandler` (`lib/src/services/notification_tap_handler.dart`)**:
  - Handles action button responses from both foreground and background isolates.
  - Implements `_handleSnooze`, `_handleDismiss`, and `_handleDone`.
- **`NotificationService` (`lib/src/services/notification_service.dart`)**:
  - Manages prayer notification scheduling; on Android, routes through `NativeReminderService`.
- **`CalendarReminderService` & `ItemReminderService`**:
  - Handles calendar and tesbihat reminders; routes scheduling through `NativeReminderService` on Android to avoid duplicate non-`deleteIntent` alarms.
- **`NotificationStrings` (`lib/src/services/notification_strings.dart`)**:
  - Centralized localized string provider for native notification titles, bodies, and action labels.

### 3. Preferences & State
- **`LocalDatabase` (`lib/src/services/local_database.dart`)**:
  - Stores `snooze_duration_minutes`.
- **`PrayerAppController` (`lib/src/controller/prayer_app_controller.dart`)**:
  - Exposes `snoozeDurationMinutes` and `updateSnoozeDurationMinutes`.
- **`PreferencesScreen` (`lib/src/ui/preferences_screen.dart`)**:
  - Dropdown selector under Reminders section.

---

## Verification & Tests
- Widget tests: `test/widget/notification_tap_handler_test.dart` (51 tests passing).
- Unit tests: `test/unit/services/calendar_reminder_service_test.dart` and `test/unit/services/item_reminder_service_test.dart` (39 tests passing).
- Clean debug APK build (`flutter build apk --debug`).
