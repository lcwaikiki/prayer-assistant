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
    this.weekdays = const [],
    this.dayOfMonth,
    this.yearlyDate,
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

  /// Weekdays (DateTime.weekday, 1=Mon..7=Sun) the reminder fires on when
  /// [recurrence] is [ReminderRecurrence.weekly]. Empty means the anchor
  /// date's weekday is used (legacy behavior).
  final List<int> weekdays;

  /// Day of month (1-31) the reminder fires on when [recurrence] is
  /// [ReminderRecurrence.monthly]: the Gregorian day-of-month, or the Hijri
  /// day when [monthlyBasis] is [CalendarBasis.hijri]. Null means the
  /// anchor date's day is used (legacy behavior).
  final int? dayOfMonth;

  /// Month/day the reminder fires on when [recurrence] is
  /// [ReminderRecurrence.yearly]: the Gregorian month/day, or the Hijri
  /// month/day when [yearlyBasis] is [CalendarBasis.hijri]. Only the month
  /// and day fields matter; the year is ignored. Null means the anchor
  /// date's month/day is used (legacy behavior).
  final DateTime? yearlyDate;

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
    List<int>? weekdays,
    int? dayOfMonth,
    DateTime? yearlyDate,
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
      weekdays: weekdays ?? this.weekdays,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      yearlyDate: yearlyDate ?? this.yearlyDate,
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
    if (!_recurrenceMatches(cursor, cursor, _recurrenceAnchorDay)) {
      // The anchor day isn't itself an occurrence (e.g. a weekly reminder
      // that repeats on selected weekdays excluding the anchor's weekday):
      // start counting from the first actual match.
      final first = _nextMatchDate(cursor);
      if (first == null) {
        return false;
      }
      cursor = first;
    }
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
        if (weekdays.isEmpty) {
          var daysUntil = (anchorDay.weekday - from.weekday) % 7;
          if (daysUntil <= 0) {
            daysUntil += 7;
          }
          return from.add(Duration(days: daysUntil));
        }
        for (var offset = 1; offset <= 7; offset++) {
          final candidate = from.add(Duration(days: offset));
          if (weekdays.contains(candidate.weekday)) {
            return candidate;
          }
        }
        return null;
      case ReminderRecurrence.monthly:
        if (monthlyBasis == CalendarBasis.gregorian) {
          final targetDay = dayOfMonth ?? anchorDay.day;
          for (var offset = 1; offset <= 12; offset++) {
            final year = from.year + ((from.month - 1 + offset) ~/ 12);
            final month = ((from.month - 1 + offset) % 12) + 1;
            final daysInMonth = DateTime(year, month + 1, 0).day;
            if (targetDay > daysInMonth) {
              continue;
            }
            return DateTime(year, month, targetDay);
          }
          return null;
        }
        final calendar = HijriCalendar();
        final anchorHijri = HijriCalendar.fromDate(anchorDay);
        final targetDay = dayOfMonth ?? anchorHijri.hDay;
        final fromHijri = HijriCalendar.fromDate(
          from.add(const Duration(days: 1)),
        );
        for (var monthOffset = 0; monthOffset < 12; monthOffset++) {
          final totalMonths =
              (fromHijri.hYear * 12 + (fromHijri.hMonth - 1)) + monthOffset;
          final hYear = totalMonths ~/ 12;
          final hMonth = (totalMonths % 12) + 1;
          if (targetDay > calendar.getDaysInMonth(hYear, hMonth)) {
            continue;
          }
          final candidateDate = calendar.hijriToGregorian(
            hYear,
            hMonth,
            targetDay,
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
          final month = yearlyDate?.month ?? anchorDay.month;
          final day = yearlyDate?.day ?? anchorDay.day;
          for (final year in [from.year, from.year + 1]) {
            final candidate = DateTime(year, month, day);
            if (candidate.isAfter(from)) {
              return candidate;
            }
          }
          return null;
        }
        final calendar = HijriCalendar();
        final anchorHijri = HijriCalendar.fromDate(yearlyDate ?? anchorDay);
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
        if (weekdays.isNotEmpty) {
          return weekdays.contains(day.weekday);
        }
        return day.weekday == anchorDay.weekday;
      case ReminderRecurrence.monthly:
        if (monthlyBasis == CalendarBasis.gregorian) {
          return day.day == (dayOfMonth ?? anchorDay.day);
        }
        final dayHijri = HijriCalendar.fromDate(day);
        final anchorHijri = HijriCalendar.fromDate(anchor);
        return dayHijri.hDay == (dayOfMonth ?? anchorHijri.hDay);
      case ReminderRecurrence.yearly:
        if (yearlyBasis == CalendarBasis.gregorian) {
          return day.month == (yearlyDate?.month ?? anchorDay.month) &&
              day.day == (yearlyDate?.day ?? anchorDay.day);
        }
        final dayHijri = HijriCalendar.fromDate(day);
        final anchorHijri = HijriCalendar.fromDate(yearlyDate ?? anchor);
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
    var ordinal = 1;
    while (count == null || ordinal <= count) {
      if (!_recurrenceMatches(cursor, cursor, _recurrenceAnchorDay)) {
        // The anchor day isn't itself an occurrence (e.g. weekly on
        // selected weekdays excluding the anchor's weekday): jump to the
        // first actual match before counting occurrences.
        final normalized = _nextMatchDate(cursor);
        if (normalized == null) {
          return null;
        }
        cursor = normalized;
      }
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
        ordinal++;
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
      'weekdays': weekdays.join(','),
      'day_of_month': dayOfMonth,
      'yearly_date': yearlyDate?.toIso8601String(),
    };
  }

  factory CalendarReminder.fromMap(Map<String, Object?> map) {
    final anchor = CalendarReminderAnchor.fromName(map['anchor']?.toString());
    final rawAnchorDate = map['anchor_date']?.toString();
    final anchorDate = (rawAnchorDate == null || rawAnchorDate.isEmpty)
        ? null
        : DateTime.tryParse(rawAnchorDate);
    final rawYearlyDate = map['yearly_date']?.toString();
    final yearlyDate = (rawYearlyDate == null || rawYearlyDate.isEmpty)
        ? null
        : DateTime.tryParse(rawYearlyDate);
    final weekdays = (map['weekdays']?.toString() ?? '')
        .split(',')
        .map((part) => int.tryParse(part.trim()))
        .whereType<int>()
        .where((day) => day >= 1 && day <= 7)
        .toList(growable: false);
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
      weekdays: weekdays,
      dayOfMonth: (map['day_of_month'] as num?)?.toInt(),
      yearlyDate: yearlyDate,
    );
  }
}
