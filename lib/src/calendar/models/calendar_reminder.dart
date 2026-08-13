import 'package:hijri/hijri_calendar.dart';

enum ReminderRecurrence {
  once,
  daily,
  weekly,
  monthly,
  yearly;

  static ReminderRecurrence fromName(String? name) {
    return ReminderRecurrence.values.firstWhere(
      (value) => value.name == name,
      orElse: () => ReminderRecurrence.once,
    );
  }
}

enum YearlyCalendarBasis {
  gregorian,
  hijri;

  static YearlyCalendarBasis fromName(String? name) {
    return YearlyCalendarBasis.values.firstWhere(
      (value) => value.name == name,
      orElse: () => YearlyCalendarBasis.gregorian,
    );
  }
}

class CalendarReminder {
  const CalendarReminder({
    required this.id,
    required this.title,
    this.notes = '',
    required this.anchorAt,
    this.recurrence = ReminderRecurrence.once,
    this.yearlyBasis = YearlyCalendarBasis.gregorian,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String notes;

  /// For [ReminderRecurrence.once] this is the exact moment the reminder
  /// fires. For every other recurrence, the date part anchors which
  /// day-of-week/day-of-month/day-of-year it repeats on and the time part is
  /// the fire time.
  final DateTime anchorAt;

  final ReminderRecurrence recurrence;

  /// Only meaningful when [recurrence] is [ReminderRecurrence.yearly].
  final YearlyCalendarBasis yearlyBasis;

  final bool enabled;

  CalendarReminder copyWith({
    String? title,
    String? notes,
    DateTime? anchorAt,
    ReminderRecurrence? recurrence,
    YearlyCalendarBasis? yearlyBasis,
    bool? enabled,
  }) {
    return CalendarReminder(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      anchorAt: anchorAt ?? this.anchorAt,
      recurrence: recurrence ?? this.recurrence,
      yearlyBasis: yearlyBasis ?? this.yearlyBasis,
      enabled: enabled ?? this.enabled,
    );
  }

  /// Whether this reminder falls on [date] (time-of-day ignored), given its
  /// recurrence rule. Used both for the calendar's day markers and the
  /// day-detail list.
  bool occursOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final anchor = DateTime(anchorAt.year, anchorAt.month, anchorAt.day);
    if (day.isBefore(anchor)) {
      return false;
    }
    switch (recurrence) {
      case ReminderRecurrence.once:
        return day == anchor;
      case ReminderRecurrence.daily:
        return true;
      case ReminderRecurrence.weekly:
        return day.weekday == anchor.weekday;
      case ReminderRecurrence.monthly:
        return day.day == anchor.day;
      case ReminderRecurrence.yearly:
        if (yearlyBasis == YearlyCalendarBasis.gregorian) {
          return day.month == anchor.month && day.day == anchor.day;
        }
        final dayHijri = HijriCalendar.fromDate(day);
        final anchorHijri = HijriCalendar.fromDate(anchor);
        return dayHijri.hMonth == anchorHijri.hMonth &&
            dayHijri.hDay == anchorHijri.hDay;
    }
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'anchor_at': anchorAt.toIso8601String(),
      'recurrence': recurrence.name,
      'yearly_basis': yearlyBasis.name,
      'enabled': enabled ? 1 : 0,
    };
  }

  factory CalendarReminder.fromMap(Map<String, Object?> map) {
    return CalendarReminder(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      notes: (map['notes'] ?? '').toString(),
      anchorAt: DateTime.parse((map['anchor_at'] ?? '').toString()),
      recurrence: ReminderRecurrence.fromName(map['recurrence']?.toString()),
      yearlyBasis: YearlyCalendarBasis.fromName(
        map['yearly_basis']?.toString(),
      ),
      enabled: (map['enabled'] as int? ?? 1) == 1,
    );
  }
}
