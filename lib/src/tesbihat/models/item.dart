import '../../calendar/models/calendar_reminder.dart';

enum ItemReminderAnchor {
  /// A fixed clock time picked directly (once or daily).
  clockTime,

  /// Tied to one of the day's prayer times plus an offset. Honors
  /// [ReminderRecurrence] by firing on each matching occurrence's prayer
  /// time (which shifts day to day); the concrete fire time is re-resolved
  /// each time the reminder is (re)scheduled.
  prayerTime;

  static ItemReminderAnchor fromName(String? name) {
    return ItemReminderAnchor.values.firstWhere(
      (value) => value.name == name,
      orElse: () => ItemReminderAnchor.clockTime,
    );
  }
}

class Item {
  const Item({
    required this.id,
    required this.title,
    this.notes = '',
    required this.count,
    required this.check,
    required this.setCount,
    required this.vibrationIntensity,
    this.currentProgress = 0,
    this.reminderEnabled = false,
    this.reminderRecurrence = ReminderRecurrence.once,
    this.reminderMonthlyBasis = CalendarBasis.gregorian,
    this.reminderYearlyBasis = CalendarBasis.gregorian,
    this.reminderAt,
    this.reminderAnchor = ItemReminderAnchor.clockTime,
    this.reminderPrayerName,
    this.reminderOffsetMinutes = 0,
    this.reminderAnchorDate,
  }) : assert(count > 0, 'count must be positive'),
       assert(check > 0, 'check must be positive'),
       assert(setCount >= 0, 'setCount cannot be negative'),
       assert(check * 2 <= count, 'check must not exceed half of count'),
       assert(
         vibrationIntensity >= 1 && vibrationIntensity <= 100,
         'vibrationIntensity must be between 1 and 100',
       ),
       assert(
         currentProgress >= 0 && currentProgress <= count,
         'currentProgress must be in range',
       );

  final String id;
  final String title;
  final String notes;
  final int count;
  final int check;
  final int setCount;
  final int vibrationIntensity;
  final int currentProgress;
  final bool reminderEnabled;

  /// Recurrence for both anchors. Mirrors [ReminderRecurrence]: once,
  /// daily, weekly, monthly, yearly. For
  /// [ItemReminderAnchor.clockTime] reminders the fire time is fixed and
  /// follows the recurrence directly; for
  /// [ItemReminderAnchor.prayerTime] reminders each matching occurrence's
  /// own prayer time is used (it shifts day to day).
  final ReminderRecurrence reminderRecurrence;

  /// Only meaningful when [reminderRecurrence] is [ReminderRecurrence.monthly].
  final CalendarBasis reminderMonthlyBasis;

  /// Only meaningful when [reminderRecurrence] is [ReminderRecurrence.yearly].
  final CalendarBasis reminderYearlyBasis;

  /// For [ItemReminderAnchor.clockTime] + [ReminderRecurrence.once] this is
  /// the exact moment the reminder fires. For every other recurrence the
  /// date part anchors which day-of-week/day-of-month/month-day it repeats
  /// on and the time part is the fire time. For
  /// [ItemReminderAnchor.prayerTime] this holds the most recently resolved
  /// concrete fire time; it is only used as a fallback recurrence anchor
  /// when [reminderAnchorDate] is null.
  final DateTime? reminderAt;

  final ItemReminderAnchor reminderAnchor;

  /// One of [prayerOrder]'s keys (Imsak/Gunes/Ogle/Ikindi/Aksam/Yatsi) when
  /// [reminderAnchor] is [ItemReminderAnchor.prayerTime].
  final String? reminderPrayerName;

  /// Minutes offset from the anchored prayer time: 0 = on time, negative =
  /// before, positive = after.
  final int reminderOffsetMinutes;

  /// For [ItemReminderAnchor.prayerTime] reminders the date that anchors
  /// the recurrence: which weekday (weekly), day-of-month (monthly) or
  /// month/day (yearly) the reminder repeats on. Only the date part matters.
  /// Null for legacy prayer-time reminders, which are treated as daily.
  final DateTime? reminderAnchorDate;

  Item copyWith({
    String? id,
    String? title,
    String? notes,
    int? count,
    int? check,
    int? setCount,
    int? vibrationIntensity,
    int? currentProgress,
    bool? reminderEnabled,
    ReminderRecurrence? reminderRecurrence,
    CalendarBasis? reminderMonthlyBasis,
    CalendarBasis? reminderYearlyBasis,
    DateTime? reminderAt,
    ItemReminderAnchor? reminderAnchor,
    String? reminderPrayerName,
    int? reminderOffsetMinutes,
    DateTime? reminderAnchorDate,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      count: count ?? this.count,
      check: check ?? this.check,
      setCount: setCount ?? this.setCount,
      vibrationIntensity: vibrationIntensity ?? this.vibrationIntensity,
      currentProgress: currentProgress ?? this.currentProgress,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderRecurrence: reminderRecurrence ?? this.reminderRecurrence,
      reminderMonthlyBasis:
          reminderMonthlyBasis ?? this.reminderMonthlyBasis,
      reminderYearlyBasis: reminderYearlyBasis ?? this.reminderYearlyBasis,
      reminderAt: reminderAt ?? this.reminderAt,
      reminderAnchor: reminderAnchor ?? this.reminderAnchor,
      reminderPrayerName: reminderPrayerName ?? this.reminderPrayerName,
      reminderOffsetMinutes:
          reminderOffsetMinutes ?? this.reminderOffsetMinutes,
      reminderAnchorDate: reminderAnchorDate ?? this.reminderAnchorDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'count': count,
      'check': check,
      'setCount': setCount,
      'vibrationIntensity': vibrationIntensity,
      'currentProgress': currentProgress,
      'reminderEnabled': reminderEnabled,
      'reminderRecurrence': reminderRecurrence.name,
      'reminderMonthlyBasis': reminderMonthlyBasis.name,
      'reminderYearlyBasis': reminderYearlyBasis.name,
      'reminderAt': reminderAt?.toIso8601String(),
      'reminderAnchor': reminderAnchor.name,
      'reminderPrayerName': reminderPrayerName,
      'reminderOffsetMinutes': reminderOffsetMinutes,
      'reminderAnchorDate': reminderAnchorDate?.toIso8601String(),
    };
  }

  factory Item.fromMap(Map<dynamic, dynamic> map) {
    final rawReminderAt = map['reminderAt']?.toString();
    final anchor = ItemReminderAnchor.fromName(
      map['reminderAnchor']?.toString(),
    );
    final rawAnchorDate = map['reminderAnchorDate']?.toString();
    final reminderAnchorDate = (rawAnchorDate == null || rawAnchorDate.isEmpty)
        ? null
        : DateTime.tryParse(rawAnchorDate);
    var recurrence = ReminderRecurrence.fromName(
      map['reminderRecurrence']?.toString() ??
          map['reminderRepeat']?.toString(),
    );
    // Legacy prayer-time reminders stored 'once'/'daily' but always
    // behaved as daily (the form never exposed recurrence for prayer-time
    // and the concrete time was re-resolved daily). Since they lack a
    // reminderAnchorDate, migrate them to daily to avoid a regression where
    // they'd stop repeating.
    if (anchor == ItemReminderAnchor.prayerTime && reminderAnchorDate == null) {
      recurrence = ReminderRecurrence.daily;
    }
    return Item(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      notes: (map['notes'] ?? '').toString(),
      count: (map['count'] ?? 0) as int,
      check: (map['check'] ?? 0) as int,
      setCount: (map['setCount'] ?? 0) as int,
      vibrationIntensity: (map['vibrationIntensity'] ?? 1) as int,
      currentProgress: (map['currentProgress'] ?? 0) as int,
      reminderEnabled: (map['reminderEnabled'] as bool?) ?? false,
      // reminderRecurrence is new; legacy entries stored 'reminderRepeat'
      // (once/daily) under the same value names, so fall back to it.
      reminderRecurrence: recurrence,
      reminderMonthlyBasis: CalendarBasis.fromName(
        map['reminderMonthlyBasis']?.toString(),
      ),
      reminderYearlyBasis: CalendarBasis.fromName(
        map['reminderYearlyBasis']?.toString(),
      ),
      reminderAt: (rawReminderAt == null || rawReminderAt.isEmpty)
          ? null
          : DateTime.tryParse(rawReminderAt),
      reminderAnchor: anchor,
      reminderPrayerName: map['reminderPrayerName']?.toString(),
      reminderOffsetMinutes: (map['reminderOffsetMinutes'] as num?)?.toInt() ?? 0,
      reminderAnchorDate: reminderAnchorDate,
    );
  }

  static String? validateCheckValue({
    required int? count,
    required int? check,
  }) {
    if (check == null) {
      return 'Check is required';
    }
    if (check <= 0) {
      return 'Check must be greater than 0';
    }
    if (count == null || count <= 0) {
      return 'Enter a valid count first';
    }
    if (check * 2 > count) {
      return 'Check cannot be greater than half of count';
    }
    return null;
  }

  static bool isCheckpointProgress({
    required int currentProgress,
    required int check,
  }) {
    if (currentProgress <= 0 || check <= 0) {
      return false;
    }
    return currentProgress % check == 0;
  }
}
