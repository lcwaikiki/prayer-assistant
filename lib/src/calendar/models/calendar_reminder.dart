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

enum CalendarBasis {
  gregorian,
  hijri;

  static CalendarBasis fromName(String? name) {
    return CalendarBasis.values.firstWhere(
      (value) => value.name == name,
      orElse: () => CalendarBasis.gregorian,
    );
  }
}

enum CalendarReminderAnchor {
  /// A fixed clock time, following [ReminderRecurrence].
  clockTime,

  /// Tied to one of the day's prayer times plus an offset. Follows
  /// [ReminderRecurrence]; the recurrence anchor date is
  /// [CalendarReminder.anchorDate] (falling back to [CalendarReminder.anchorAt]
  /// for legacy reminders). The concrete fire time is re-resolved by the
  /// scheduler (see CalendarMidnightScheduler).
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
    this.monthlyBasis = CalendarBasis.gregorian,
    this.yearlyBasis = CalendarBasis.gregorian,
    this.anchor = CalendarReminderAnchor.clockTime,
    this.anchorPrayerName,
    this.anchorOffsetMinutes = 0,
    this.anchorDate,
    this.enabled = true,
    this.repeatCount,
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

  /// Only meaningful when [recurrence] is [ReminderRecurrence.monthly].
  final CalendarBasis monthlyBasis;

  /// Only meaningful when [recurrence] is [ReminderRecurrence.yearly].
  final CalendarBasis yearlyBasis;

  final CalendarReminderAnchor anchor;

  /// One of [prayerOrder]'s keys (Imsak/Gunes/Ogle/Ikindi/Aksam/Yatsi) when
  /// [anchor] is [CalendarReminderAnchor.prayerTime].
  final String? anchorPrayerName;

  /// Minutes offset from the anchored prayer time: 0 = on time, negative =
  /// before, positive = after. Only meaningful for [CalendarReminderAnchor.prayerTime].
  final int anchorOffsetMinutes;

  /// Recurrence anchor date for [CalendarReminderAnchor.prayerTime]
  /// reminders whose [recurrence] isn't [ReminderRecurrence.daily]: which
  /// day-of-week/day-of-month/day-of-year the reminder repeats on. Null for
  /// legacy prayer-time reminders (always treated as daily) and for
  /// clock-time reminders ([anchorAt] anchors those instead).
  final DateTime? anchorDate;

  final bool enabled;

  /// Total number of times the reminder fires before stopping. Null means
  /// it repeats forever. Only meaningful when [recurrence] isn't
  /// [ReminderRecurrence.once].
  final int? repeatCount;

  CalendarReminder copyWith({
    String? title,
    String? notes,
    DateTime? anchorAt,
    ReminderRecurrence? recurrence,
    CalendarBasis? monthlyBasis,
    CalendarBasis? yearlyBasis,
    CalendarReminderAnchor? anchor,
    String? anchorPrayerName,
    int? anchorOffsetMinutes,
    DateTime? anchorDate,
    bool? enabled,
    int? repeatCount,
  }) {
    return CalendarReminder(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      anchorAt: anchorAt ?? this.anchorAt,
      recurrence: recurrence ?? this.recurrence,
      monthlyBasis: monthlyBasis ?? this.monthlyBasis,
      yearlyBasis: yearlyBasis ?? this.yearlyBasis,
      anchor: anchor ?? this.anchor,
      anchorPrayerName: anchorPrayerName ?? this.anchorPrayerName,
      anchorOffsetMinutes: anchorOffsetMinutes ?? this.anchorOffsetMinutes,
      anchorDate: anchorDate ?? this.anchorDate,
      enabled: enabled ?? this.enabled,
      repeatCount: repeatCount ?? this.repeatCount,
    );
  }

  /// Whether this reminder falls on [date] (time-of-day ignored). Used both
  /// for the calendar's day markers and the day-detail list. A finite
  /// [repeatCount] limits the marked days to the first N occurrences.
  ///
  /// Legacy prayer-time reminders (no [anchorDate]) always occur, since the
  /// old form only ever created daily prayer-time reminders; newer ones
  /// follow [recurrence] anchored on [anchorDate].
  bool occursOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final anchorDay = _recurrenceAnchorDay;
    if (day.isBefore(anchorDay)) {
      return false;
    }
    if (anchor == CalendarReminderAnchor.prayerTime) {
      if (anchorDate == null) {
        return _withinRepeatCount(day);
      }
      if (!_recurrenceMatches(day, anchorDay, anchorDate!)) {
        return false;
      }
      return _withinRepeatCount(day);
    }
    if (!_recurrenceMatches(day, anchorDay, anchorAt)) {
      return false;
    }
    return _withinRepeatCount(day);
  }

  /// The date part that anchors the recurrence: [anchorDate] for newer
  /// prayer-time reminders, [anchorAt] otherwise.
  DateTime get _recurrenceAnchorDay {
    final date = anchor == CalendarReminderAnchor.prayerTime
        ? (anchorDate ?? anchorAt)
        : anchorAt;
    return DateTime(date.year, date.month, date.day);
  }

  /// Whether [day] is among the first [repeatCount] occurrences. Always
  /// true when [repeatCount] is null.
  bool _withinRepeatCount(DateTime day) {
    final count = repeatCount;
    if (count == null) {
      return true;
    }
    var cursor = _recurrenceAnchorDay;
    for (var ordinal = 1; ordinal <= count; ordinal++) {
      if (cursor == day) {
        return true;
      }
      if (cursor.isAfter(day)) {
        return false;
      }
      final next = _nextMatchDate(cursor);
      if (next == null) {
        return false;
      }
      cursor = next;
    }
    return false;
  }

  /// The next occurrence date strictly after [from], following
  /// [recurrence] anchored on the recurrence anchor day. Null when there is
  /// no further occurrence (e.g. [ReminderRecurrence.once]).
  DateTime? _nextMatchDate(DateTime from) {
    final anchorDay = _recurrenceAnchorDay;
    switch (recurrence) {
      case ReminderRecurrence.once:
        return null;
      case ReminderRecurrence.daily:
        return from.add(const Duration(days: 1));
      case ReminderRecurrence.weekly:
        var daysUntil = (anchorDay.weekday - from.weekday) % 7;
        if (daysUntil <= 0) {
          daysUntil += 7;
        }
        return from.add(Duration(days: daysUntil));
      case ReminderRecurrence.monthly:
        if (monthlyBasis == CalendarBasis.gregorian) {
          for (var offset = 1; offset <= 12; offset++) {
            final year = from.year + ((from.month - 1 + offset) ~/ 12);
            final month = ((from.month - 1 + offset) % 12) + 1;
            final daysInMonth = DateTime(year, month + 1, 0).day;
            if (anchorDay.day > daysInMonth) {
              continue;
            }
            return DateTime(year, month, anchorDay.day);
          }
          return null;
        }
        final calendar = HijriCalendar();
        final anchorHijri = HijriCalendar.fromDate(anchorDay);
        final fromHijri = HijriCalendar.fromDate(
          from.add(const Duration(days: 1)),
        );
        for (var monthOffset = 0; monthOffset < 12; monthOffset++) {
          final totalMonths =
              (fromHijri.hYear * 12 + (fromHijri.hMonth - 1)) + monthOffset;
          final hYear = totalMonths ~/ 12;
          final hMonth = (totalMonths % 12) + 1;
          if (anchorHijri.hDay > calendar.getDaysInMonth(hYear, hMonth)) {
            continue;
          }
          final candidateDate = calendar.hijriToGregorian(
            hYear,
            hMonth,
            anchorHijri.hDay,
          );
          final candidate = DateTime(
            candidateDate.year,
            candidateDate.month,
            candidateDate.day,
          );
          if (candidate.isAfter(from)) {
            return candidate;
          }
        }
        return null;
      case ReminderRecurrence.yearly:
        if (yearlyBasis == CalendarBasis.gregorian) {
          for (final year in [from.year, from.year + 1]) {
            final candidate = DateTime(year, anchorDay.month, anchorDay.day);
            if (candidate.isAfter(from)) {
              return candidate;
            }
          }
          return null;
        }
        final calendar = HijriCalendar();
        final anchorHijri = HijriCalendar.fromDate(anchorDay);
        final fromHijri = HijriCalendar.fromDate(from);
        for (final hYear in [fromHijri.hYear, fromHijri.hYear + 1]) {
          final candidateDate = calendar.hijriToGregorian(
            hYear,
            anchorHijri.hMonth,
            anchorHijri.hDay,
          );
          final candidate = DateTime(
            candidateDate.year,
            candidateDate.month,
            candidateDate.day,
          );
          if (candidate.isAfter(from)) {
            return candidate;
          }
        }
        return null;
    }
  }

  bool _recurrenceMatches(DateTime day, DateTime anchorDay, DateTime anchor) {
    switch (recurrence) {
      case ReminderRecurrence.once:
        return day == anchorDay;
      case ReminderRecurrence.daily:
        return true;
      case ReminderRecurrence.weekly:
        return day.weekday == anchorDay.weekday;
      case ReminderRecurrence.monthly:
        if (monthlyBasis == CalendarBasis.gregorian) {
          return day.day == anchorDay.day;
        }
        final dayHijri = HijriCalendar.fromDate(day);
        final anchorHijri = HijriCalendar.fromDate(anchor);
        return dayHijri.hDay == anchorHijri.hDay;
      case ReminderRecurrence.yearly:
        if (yearlyBasis == CalendarBasis.gregorian) {
          return day.month == anchorDay.month && day.day == anchorDay.day;
        }
        final dayHijri = HijriCalendar.fromDate(day);
        final anchorHijri = HijriCalendar.fromDate(anchor);
        return dayHijri.hMonth == anchorHijri.hMonth &&
            dayHijri.hDay == anchorHijri.hDay;
    }
  }

  /// The next moment at or after [from] this reminder occurs, combining
  /// the occurrence pattern (with [repeatCount] limiting the first N
  /// occurrences) with [anchorAt]'s time-of-day. Null if disabled or
  /// nothing remains. Used for "upcoming reminders" surfaces rather than
  /// for actual notification scheduling.
  DateTime? nextOccurrenceFrom(DateTime from) {
    if (!enabled) {
      return null;
    }
    final count = repeatCount;
    var cursor = _recurrenceAnchorDay;
    for (var ordinal = 1; count == null || ordinal <= count; ordinal++) {
      final candidate = DateTime(
        cursor.year,
        cursor.month,
        cursor.day,
        anchorAt.hour,
        anchorAt.minute,
      );
      if (candidate.isBefore(from)) {
        final next = _nextMatchDate(cursor);
        if (next == null) {
          return null;
        }
        cursor = next;
        continue;
      }
      return candidate;
    }
    return null;
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'anchor_at': anchorAt.toIso8601String(),
      'recurrence': recurrence.name,
      'monthly_basis': monthlyBasis.name,
      'yearly_basis': yearlyBasis.name,
      'anchor': anchor.name,
      'anchor_prayer_name': anchorPrayerName,
      'anchor_offset_minutes': anchorOffsetMinutes,
      'anchor_date': anchorDate?.toIso8601String(),
      'enabled': enabled ? 1 : 0,
      'repeat_count': repeatCount,
    };
  }

  factory CalendarReminder.fromMap(Map<String, Object?> map) {
    final anchor = CalendarReminderAnchor.fromName(map['anchor']?.toString());
    final rawAnchorDate = map['anchor_date']?.toString();
    final anchorDate = (rawAnchorDate == null || rawAnchorDate.isEmpty)
        ? null
        : DateTime.tryParse(rawAnchorDate);
    var recurrence = ReminderRecurrence.fromName(map['recurrence']?.toString());
    // Legacy prayer-time reminders stored any recurrence but always behaved
    // as daily (the old form never exposed recurrence for prayer time and
    // the concrete time was re-resolved daily). Since they lack an
    // anchorDate, migrate them to daily to avoid a regression where they'd
    // stop repeating.
    if (anchor == CalendarReminderAnchor.prayerTime && anchorDate == null) {
      recurrence = ReminderRecurrence.daily;
    }
    return CalendarReminder(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      notes: (map['notes'] ?? '').toString(),
      anchorAt: DateTime.parse((map['anchor_at'] ?? '').toString()),
      recurrence: recurrence,
      monthlyBasis: CalendarBasis.fromName(map['monthly_basis']?.toString()),
      yearlyBasis: CalendarBasis.fromName(map['yearly_basis']?.toString()),
      anchor: anchor,
      anchorPrayerName: map['anchor_prayer_name']?.toString(),
      anchorOffsetMinutes: (map['anchor_offset_minutes'] as num?)?.toInt() ?? 0,
      anchorDate: anchorDate,
      enabled: (map['enabled'] as int? ?? 1) == 1,
      repeatCount: (map['repeat_count'] as num?)?.toInt(),
    );
  }
}
