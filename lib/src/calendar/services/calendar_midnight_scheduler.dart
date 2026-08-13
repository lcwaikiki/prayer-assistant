import 'dart:io' show Platform;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';

import '../../services/local_database.dart';
import '../../tesbihat/services/prayer_anchor_resolver.dart';
import '../models/calendar_reminder.dart';
import 'calendar_reminder_service.dart';

const _calendarMidnightAlarmId = 5002;

/// Re-resolves and re-schedules every calendar reminder whose fire time
/// can't be expressed as a fixed OS-level repeat: yearly-Hijri-basis
/// reminders (no native way to repeat on a fixed Hijri month/day, unlike
/// Gregorian-yearly which uses [DateTimeComponents.dateAndTime]) and
/// prayer-time-anchored reminders (the underlying prayer time shifts by a
/// few minutes day to day). Runs once daily just after midnight.
/// Android-only: iOS refreshes these on next app open instead (see
/// PrayerAppController.initialize).
@pragma('vm:entry-point')
Future<void> calendarMidnightRefreshCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = LocalDatabase();
  final reminderService = CalendarReminderService();
  await reminderService.initialize();

  final reminders = await database.loadCalendarReminders();
  final updatedReminders = <CalendarReminder>[];
  var changed = false;

  for (final reminder in reminders) {
    if (!reminder.enabled) {
      continue;
    }
    if (reminder.anchor == CalendarReminderAnchor.prayerTime) {
      final resolved = await resolvePrayerAnchoredTime(
        database,
        prayerName: reminder.anchorPrayerName,
        offsetMinutes: reminder.anchorOffsetMinutes,
      );
      if (resolved != null) {
        final updated = reminder.copyWith(anchorAt: resolved);
        updatedReminders.add(updated);
        changed = true;
        await reminderService.scheduleReminder(updated);
        continue;
      }
    } else if (reminder.recurrence == ReminderRecurrence.yearly &&
        reminder.yearlyBasis == YearlyCalendarBasis.hijri) {
      await reminderService.scheduleReminder(reminder);
    }
  }

  if (changed) {
    for (final reminder in updatedReminders) {
      await database.saveCalendarReminder(reminder);
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
