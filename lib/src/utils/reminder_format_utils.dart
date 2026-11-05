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

  final String repeatSuffix = (repeatCount != null && repeatCount > 0)
      ? (l10n != null
          ? l10n.reminderRepeatCountSuffix(repeatCount.toString())
          : ' ($repeatCount times)')
      : '';

  if (isPrayerAnchor) {
    final rawName = prayerName ?? 'Isha';
    final pName = l10n?.prayerNameLabel(rawName) ?? rawName;
    final String offsetPhrase;
    if (offsetMinutes == 0) {
      offsetPhrase = l10n != null
          ? l10n.reminderPrayerOffsetOnTime(pName)
          : 'at $pName prayer';
    } else if (offsetMinutes > 0) {
      offsetPhrase = l10n != null
          ? l10n.reminderPrayerOffsetAfter(offsetMinutes.toString(), pName)
          : '$offsetMinutes minutes after $pName prayer';
    } else {
      offsetPhrase = l10n != null
          ? l10n.reminderPrayerOffsetBefore((-offsetMinutes).toString(), pName)
          : '${-offsetMinutes} minutes before $pName prayer';
    }

    switch (recurrence) {
      case ReminderRecurrence.once:
        if (anchorDate != null) {
          final dateStr = DateFormat.yMMMd(locale).format(anchorDate);
          return l10n != null
              ? '${l10n.reminderRecurrenceOnceOnDate(dateStr, offsetPhrase)}$repeatSuffix'
              : 'Once on $dateStr $offsetPhrase$repeatSuffix';
        }
        return l10n != null
            ? '${l10n.reminderRecurrenceOnce(offsetPhrase)}$repeatSuffix'
            : 'Once $offsetPhrase$repeatSuffix';
      case ReminderRecurrence.daily:
        return l10n != null
            ? '${l10n.reminderRecurrenceDaily(offsetPhrase)}$repeatSuffix'
            : 'Daily $offsetPhrase$repeatSuffix';
      case ReminderRecurrence.weekly:
        if (weekdays.isNotEmpty) {
          final sortedWeekdays = List<int>.from(weekdays)..sort();
          final days = sortedWeekdays
              .map((w) => DateFormat.EEEE(locale).format(DateTime(2024, 1, w)))
              .join(', ');
          return l10n != null
              ? '${l10n.reminderRecurrenceWeekly(days, offsetPhrase)}$repeatSuffix'
              : 'every $days $offsetPhrase$repeatSuffix';
        }
        return l10n != null
            ? '${l10n.reminderRecurrenceWeeklyGeneral(offsetPhrase)}$repeatSuffix'
            : 'Every week $offsetPhrase$repeatSuffix';
      case ReminderRecurrence.monthly:
        final day = dayOfMonth ?? anchorDate?.day ?? 1;
        final basis = monthlyBasis == CalendarBasis.hijri ? ' (Hijri)' : '';
        return l10n != null
            ? '${l10n.reminderRecurrenceMonthly(day.toString(), basis, offsetPhrase)}$repeatSuffix'
            : 'Every month on day $day$basis $offsetPhrase$repeatSuffix';
      case ReminderRecurrence.yearly:
        final date = yearlyDate ?? anchorDate;
        final dateStr =
            date != null ? DateFormat.MMMd(locale).format(date) : '';
        final basis = yearlyBasis == CalendarBasis.hijri ? ' (Hijri)' : '';
        return l10n != null
            ? '${l10n.reminderRecurrenceYearly(dateStr, basis, offsetPhrase)}$repeatSuffix'
            : 'Every year on $dateStr$basis $offsetPhrase$repeatSuffix';
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
    final timePhrase = l10n != null
        ? l10n.reminderClockTimeAt(timeStr)
        : 'at $timeStr';

    switch (recurrence) {
      case ReminderRecurrence.once:
        final date = anchorAt ?? anchorDate;
        if (date != null) {
          final dateStr = DateFormat.yMMMd(locale).format(date);
          return l10n != null
              ? '${l10n.reminderRecurrenceOnceOnDate(dateStr, timePhrase)}$repeatSuffix'
              : 'Once on $dateStr $timePhrase$repeatSuffix';
        }
        return l10n != null
            ? '${l10n.reminderRecurrenceOnce(timePhrase)}$repeatSuffix'
            : 'Once $timePhrase$repeatSuffix';
      case ReminderRecurrence.daily:
        return l10n != null
            ? '${l10n.reminderRecurrenceDaily(timePhrase)}$repeatSuffix'
            : 'Daily $timePhrase$repeatSuffix';
      case ReminderRecurrence.weekly:
        if (weekdays.isNotEmpty) {
          final sortedWeekdays = List<int>.from(weekdays)..sort();
          final days = sortedWeekdays
              .map((w) => DateFormat.EEEE(locale).format(DateTime(2024, 1, w)))
              .join(', ');
          return l10n != null
              ? '${l10n.reminderRecurrenceWeekly(days, timePhrase)}$repeatSuffix'
              : 'Every $days $timePhrase$repeatSuffix';
        }
        return l10n != null
            ? '${l10n.reminderRecurrenceWeeklyGeneral(timePhrase)}$repeatSuffix'
            : 'Every week $timePhrase$repeatSuffix';
      case ReminderRecurrence.monthly:
        final day = dayOfMonth ?? anchorAt?.day ?? anchorDate?.day ?? 1;
        final basis = monthlyBasis == CalendarBasis.hijri ? ' (Hijri)' : '';
        return l10n != null
            ? '${l10n.reminderRecurrenceMonthly(day.toString(), basis, timePhrase)}$repeatSuffix'
            : 'Every month on day $day$basis $timePhrase$repeatSuffix';
      case ReminderRecurrence.yearly:
        final date = yearlyDate ?? anchorAt ?? anchorDate;
        final dateStr =
            date != null ? DateFormat.MMMd(locale).format(date) : '';
        final basis = yearlyBasis == CalendarBasis.hijri ? ' (Hijri)' : '';
        return l10n != null
            ? '${l10n.reminderRecurrenceYearly(dateStr, basis, timePhrase)}$repeatSuffix'
            : 'Every year on $dateStr$basis $timePhrase$repeatSuffix';
    }
  }
}
