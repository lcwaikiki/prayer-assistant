import 'dart:io' show Platform;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';

import '../../services/local_database.dart';
import '../models/calendar_reminder.dart';
import 'calendar_reminder_service.dart';

const _calendarMidnightAlarmId = 5002;

/// Re-resolves and re-schedules every calendar reminder whose fire time
/// can't be expressed as a fixed OS-level repeat: monthly- and
/// yearly-Hijri-basis reminders (no native way to repeat on a fixed Hijri
/// day-of-month/month-day, unlike their Gregorian equivalents which use
/// [DateTimeComponents.dayOfMonthAndTime]/[DateTimeComponents.dateAndTime])
/// and prayer-time-anchored reminders (the underlying prayer time shifts by
/// a few minutes day to day, so the next occurrence is re-resolved and
/// re-armed nightly). Runs once daily just after midnight.
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
    if (reminder.anchor == CalendarReminderAnchor.prayerTime) {
      // Re-resolve the next occurrence's prayer time (advances each day or
      // to the next matching weekday/month-day), honoring recurrence.
      // catchUp is false so a just-fired occurrence is not re-notified.
      await reminderService.scheduleReminder(reminder, catchUp: false);
    } else if ((reminder.recurrence == ReminderRecurrence.monthly &&
            reminder.monthlyBasis == CalendarBasis.hijri) ||
        (reminder.recurrence == ReminderRecurrence.yearly &&
            reminder.yearlyBasis == CalendarBasis.hijri)) {
      await reminderService.scheduleReminder(reminder, catchUp: false);
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
