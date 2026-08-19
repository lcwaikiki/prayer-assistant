import 'dart:io' show Platform;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';

import '../../services/local_database.dart';
import 'calendar_reminder_service.dart';

const _calendarMidnightAlarmId = 5002;

/// Re-resolves and re-schedules every enabled calendar reminder nightly.
/// This advances the app-managed one-shot chains on Android (where the
/// plugin's OS-level repeats are avoided because they can double-fire) for
/// all recurrences, and is required for prayer-anchored and Hijri-basis
/// reminders on both platforms (no native repeat for a floating prayer time
/// or Hijri day-of-month/month-day; their Gregorian equivalents could use
/// [DateTimeComponents.dayOfMonthAndTime]/[DateTimeComponents.dateAndTime]
/// on iOS only). Runs once daily just after midnight.
/// Android-only: iOS refreshes these on next app open instead (see
/// PrayerAppController.initialize).
@pragma('vm:entry-point')
Future<void> calendarMidnightRefreshCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = LocalDatabase();
  final reminderService = CalendarReminderService();
  await reminderService.initialize();

  final reminders = await database.loadCalendarReminders();

  for (final reminder in reminders) {
    if (!reminder.enabled) {
      continue;
    }
    // Re-resolve the next occurrence (advances each day or to the next
    // matching weekday/month-day), honoring recurrence. catchUp is false
    // so a just-fired occurrence is not re-notified.
    await reminderService.scheduleReminder(reminder, catchUp: false);
  }
}

class CalendarMidnightScheduler {
  /// Arms the daily midnight refresh alarm. Safe to call every app start;
  /// re-registering with the same id just resets the existing alarm. No-op
  /// on platforms other than Android.
  static Future<void> initializeAndSchedule() async {
    if (!Platform.isAndroid) {
      return;
    }
    await AndroidAlarmManager.initialize();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      _calendarMidnightAlarmId,
      calendarMidnightRefreshCallback,
      startAt: nextMidnight,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }
}
