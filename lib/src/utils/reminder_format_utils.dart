import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../calendar/models/calendar_reminder.dart';
import '../../l10n/app_localizations.dart';
import '../l10n/prayer_names.dart';
import '../tesbihat/l10n/tesbihat_localizations.dart';

/// Formats reminder timing and recurrence into a human-readable concise text
/// string, avoiding button controls or pickers.
String formatConciseReminder({
  required BuildContext context,
  required bool enabled,
  required bool isPrayerAnchor,
  required ReminderRecurrence recurrence,
  String? prayerName,
  int offsetMinutes = 0,
  DateTime? anchorDate,
  DateTime? anchorAt,
  TimeOfDay? clockTime,
  List<int> weekdays = const [],
  int? dayOfMonth,
  DateTime? yearlyDate,
  CalendarBasis monthlyBasis = CalendarBasis.gregorian,
  CalendarBasis yearlyBasis = CalendarBasis.gregorian,
  int? repeatCount,
}) {
  final l10n = AppLocalizations.of(context);
  final tesbihatL10n = context.tesbihatL10n;

  if (!enabled) {
    return l10n?.reminderOff ?? tesbihatL10n.reminderNotSet;
  }

  final locale = Localizations.localeOf(context).toString();

  if (isPrayerAnchor) {
    final rawName = prayerName ?? 'Isha';
    final pName = l10n?.prayerNameLabel(rawName) ?? rawName;
    final String offsetPhrase;
    if (offsetMinutes == 0) {
      offsetPhrase = 'at $pName prayer';
    } else if (offsetMinutes > 0) {
      offsetPhrase = '$offsetMinutes minutes after $pName prayer';
    } else {
      offsetPhrase = '${-offsetMinutes} minutes before $pName prayer';
    }

    final String repeatSuffix =
        (repeatCount != null && repeatCount > 0) ? ' ($repeatCount times)' : '';

    switch (recurrence) {
      case ReminderRecurrence.once:
        if (anchorDate != null) {
          final dateStr = DateFormat.yMMMd(locale).format(anchorDate);
          return 'Once on $dateStr $offsetPhrase$repeatSuffix';
        }
        return 'Once $offsetPhrase$repeatSuffix';
      case ReminderRecurrence.daily:
        return 'Daily $offsetPhrase$repeatSuffix';
      case ReminderRecurrence.weekly:
        if (weekdays.isNotEmpty) {
          final sortedWeekdays = List<int>.from(weekdays)..sort();
          final days = sortedWeekdays
              .map((w) => DateFormat.EEEE(locale).format(DateTime(2024, 1, w)))
              .join(', ');
          return 'every $days $offsetPhrase$repeatSuffix';
        }
        return 'Every week $offsetPhrase$repeatSuffix';
      case ReminderRecurrence.monthly:
        final day = dayOfMonth ?? anchorDate?.day ?? 1;
        final basis = monthlyBasis == CalendarBasis.hijri ? ' (Hijri)' : '';
        return 'Every month on day $day$basis $offsetPhrase$repeatSuffix';
      case ReminderRecurrence.yearly:
        final date = yearlyDate ?? anchorDate;
        final dateStr =
            date != null ? DateFormat.MMMd(locale).format(date) : '';
        final basis = yearlyBasis == CalendarBasis.hijri ? ' (Hijri)' : '';
        return 'Every year on $dateStr$basis $offsetPhrase$repeatSuffix';
    }
  } else {
    // Clock time anchor
    final TimeOfDay time;
    if (clockTime != null) {
      time = clockTime;
    } else if (anchorAt != null) {
      time = TimeOfDay(hour: anchorAt.hour, minute: anchorAt.minute);
    } else {
      time = const TimeOfDay(hour: 9, minute: 0);
    }

    final timeStr = MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    final String repeatSuffix =
        (repeatCount != null && repeatCount > 0) ? ' ($repeatCount times)' : '';

    switch (recurrence) {
      case ReminderRecurrence.once:
        final date = anchorAt ?? anchorDate;
        if (date != null) {
          final dateStr = DateFormat.yMMMd(locale).format(date);
          return 'Once on $dateStr at $timeStr$repeatSuffix';
        }
        return 'Once at $timeStr$repeatSuffix';
      case ReminderRecurrence.daily:
        return 'Daily at $timeStr$repeatSuffix';
      case ReminderRecurrence.weekly:
        if (weekdays.isNotEmpty) {
          final sortedWeekdays = List<int>.from(weekdays)..sort();
          final days = sortedWeekdays
              .map((w) => DateFormat.EEEE(locale).format(DateTime(2024, 1, w)))
              .join(', ');
          return 'Every $days at $timeStr$repeatSuffix';
        }
        return 'Every week at $timeStr$repeatSuffix';
      case ReminderRecurrence.monthly:
        final day = dayOfMonth ?? anchorAt?.day ?? anchorDate?.day ?? 1;
        final basis = monthlyBasis == CalendarBasis.hijri ? ' (Hijri)' : '';
        return 'Every month on day $day$basis at $timeStr$repeatSuffix';
      case ReminderRecurrence.yearly:
        final date = yearlyDate ?? anchorAt ?? anchorDate;
        final dateStr =
            date != null ? DateFormat.MMMd(locale).format(date) : '';
        final basis = yearlyBasis == CalendarBasis.hijri ? ' (Hijri)' : '';
        return 'Every year on $dateStr$basis at $timeStr$repeatSuffix';
    }
  }
}

