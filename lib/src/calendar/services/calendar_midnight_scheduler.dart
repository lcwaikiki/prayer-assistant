import 'dart:io' show Platform;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';

import '../../services/local_database.dart';
import '../models/calendar_reminder.dart';
import 'calendar_reminder_service.dart';

const _calendarMidnightAlarmId = 5002;

/// Re-resolves and re-schedules every yearly-Hijri-basis calendar reminder
/// once a day, since the plugin has no native way to repeat on a fixed
/// Hijri month/day (unlike Gregorian-yearly, which uses
/// [DateTimeComponents.dateAndTime] and never needs this). Android-only:
/// iOS refreshes these on next app open instead (see
/// PrayerAppController.initialize).
@pragma('vm:entry-point')
Future<void> calendarMidnightRefreshCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = LocalDatabase();
  final reminderService = CalendarReminderService();
  await reminderService.initialize();

  final reminders = await database.loadCalendarReminders();
  for (final reminder in reminders) {
    if (reminder.enabled &&
        reminder.recurrence == ReminderRecurrence.yearly &&
        reminder.yearlyBasis == YearlyCalendarBasis.hijri) {
      await reminderService.scheduleReminder(reminder);
    }
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
