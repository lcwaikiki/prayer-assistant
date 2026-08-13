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

enum CalendarReminderAnchor {
  /// A fixed clock time, following [ReminderRecurrence].
  clockTime,

  /// Tied to one of the day's prayer times plus an offset. Always behaves
  /// as a recurring-daily reminder since prayer times repeat daily by
  /// nature; [ReminderRecurrence] is ignored. The concrete fire time is
  /// re-resolved each day (see CalendarMidnightScheduler).
  prayerTime;

  static CalendarReminderAnchor fromName(String? name) {
    return CalendarReminderAnchor.values.firstWhere(
      (value) => value.name == name,
      orElse: () => CalendarReminderAnchor.clockTime,
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
    this.anchor = CalendarReminderAnchor.clockTime,
    this.anchorPrayerName,
    this.anchorOffsetMinutes = 0,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String notes;

  /// For [ReminderRecurrence.once] this is the exact moment the reminder
  /// fires. For every other recurrence, the date part anchors which
  /// day-of-week/day-of-month/day-of-year it repeats on and the time part is
  /// the fire time. For [CalendarReminderAnchor.prayerTime] this holds the
  /// most recently resolved concrete fire time (recomputed daily).
  final DateTime anchorAt;

  final ReminderRecurrence recurrence;

  /// Only meaningful when [recurrence] is [ReminderRecurrence.yearly].
  final YearlyCalendarBasis yearlyBasis;

  final CalendarReminderAnchor anchor;

  /// One of [prayerOrder]'s keys (Imsak/Gunes/Ogle/Ikindi/Aksam/Yatsi) when
  /// [anchor] is [CalendarReminderAnchor.prayerTime].
  final String? anchorPrayerName;

  /// Minutes offset from the anchored prayer time: 0 = on time, negative =
  /// before, positive = after. Only meaningful for [CalendarReminderAnchor.prayerTime].
  final int anchorOffsetMinutes;

  final bool enabled;

  CalendarReminder copyWith({
    String? title,
    String? notes,
    DateTime? anchorAt,
    ReminderRecurrence? recurrence,
    YearlyCalendarBasis? yearlyBasis,
    CalendarReminderAnchor? anchor,
    String? anchorPrayerName,
    int? anchorOffsetMinutes,
    bool? enabled,
  }) {
    return CalendarReminder(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      anchorAt: anchorAt ?? this.anchorAt,
      recurrence: recurrence ?? this.recurrence,
      yearlyBasis: yearlyBasis ?? this.yearlyBasis,
      anchor: anchor ?? this.anchor,
      anchorPrayerName: anchorPrayerName ?? this.anchorPrayerName,
      anchorOffsetMinutes: anchorOffsetMinutes ?? this.anchorOffsetMinutes,
      enabled: enabled ?? this.enabled,
    );
  }

  /// Whether this reminder falls on [date] (time-of-day ignored). Used both
  /// for the calendar's day markers and the day-detail list.
  bool occursOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final anchorDay = DateTime(anchorAt.year, anchorAt.month, anchorAt.day);
    if (day.isBefore(anchorDay)) {
      return false;
    }
    if (anchor == CalendarReminderAnchor.prayerTime) {
      return true;
    }
    switch (recurrence) {
      case ReminderRecurrence.once:
        return day == anchorDay;
      case ReminderRecurrence.daily:
        return true;
      case ReminderRecurrence.weekly:
        return day.weekday == anchorDay.weekday;
      case ReminderRecurrence.monthly:
        return day.day == anchorDay.day;
      case ReminderRecurrence.yearly:
        if (yearlyBasis == YearlyCalendarBasis.gregorian) {
          return day.month == anchorDay.month && day.day == anchorDay.day;
        }
        final dayHijri = HijriCalendar.fromDate(day);
        final anchorHijri = HijriCalendar.fromDate(anchorDay);
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
      'anchor': anchor.name,
      'anchor_prayer_name': anchorPrayerName,
      'anchor_offset_minutes': anchorOffsetMinutes,
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
      anchor: CalendarReminderAnchor.fromName(map['anchor']?.toString()),
      anchorPrayerName: map['anchor_prayer_name']?.toString(),
      anchorOffsetMinutes: (map['anchor_offset_minutes'] as num?)?.toInt() ?? 0,
      enabled: (map['enabled'] as int? ?? 1) == 1,
    );
  }
}
