import '../../calendar/models/calendar_reminder.dart';
import 'item.dart';
import 'reminder_schedulable.dart';

/// A container holding one or more beads ([Item]s whose [Item.groupIds]
/// contain this group's id). A group is not a counter itself; it only
/// organizes beads and can carry its own reminder with the exact same
/// options as a bead reminder.
class ItemGroup implements ReminderSchedulable {
  const ItemGroup({
    required this.id,
    required this.title,
    this.reminderEnabled = false,
    this.reminderRecurrence = ReminderRecurrence.once,
    this.reminderMonthlyBasis = CalendarBasis.gregorian,
    this.reminderYearlyBasis = CalendarBasis.gregorian,
    this.reminderAt,
    this.reminderAnchor = ItemReminderAnchor.clockTime,
    this.reminderPrayerName,
    this.reminderOffsetMinutes = 0,
    this.reminderAnchorDate,
    this.reminderRepeatCount,
    this.reminderWeekdays = const [],
    this.reminderDayOfMonth,
    this.reminderYearlyDate,
  });

  final String id;
  final String title;
  final bool reminderEnabled;
  final ReminderRecurrence reminderRecurrence;
  final CalendarBasis reminderMonthlyBasis;
  final CalendarBasis reminderYearlyBasis;
  final DateTime? reminderAt;
  final ItemReminderAnchor reminderAnchor;
  final String? reminderPrayerName;
  final int reminderOffsetMinutes;
  final DateTime? reminderAnchorDate;
  final int? reminderRepeatCount;
  final List<int> reminderWeekdays;
  final int? reminderDayOfMonth;
  final DateTime? reminderYearlyDate;

  ItemGroup copyWith({
    String? id,
    String? title,
    bool? reminderEnabled,
    ReminderRecurrence? reminderRecurrence,
    CalendarBasis? reminderMonthlyBasis,
    CalendarBasis? reminderYearlyBasis,
    DateTime? reminderAt,
    ItemReminderAnchor? reminderAnchor,
    String? reminderPrayerName,
    int? reminderOffsetMinutes,
    DateTime? reminderAnchorDate,
    int? reminderRepeatCount,
    List<int>? reminderWeekdays,
    int? reminderDayOfMonth,
    DateTime? reminderYearlyDate,
  }) {
    return ItemGroup(
      id: id ?? this.id,
      title: title ?? this.title,
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
      reminderRepeatCount: reminderRepeatCount ?? this.reminderRepeatCount,
      reminderWeekdays: reminderWeekdays ?? this.reminderWeekdays,
      reminderDayOfMonth: reminderDayOfMonth ?? this.reminderDayOfMonth,
      reminderYearlyDate: reminderYearlyDate ?? this.reminderYearlyDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'reminderEnabled': reminderEnabled,
      'reminderRecurrence': reminderRecurrence.name,
      'reminderMonthlyBasis': reminderMonthlyBasis.name,
      'reminderYearlyBasis': reminderYearlyBasis.name,
      'reminderAt': reminderAt?.toIso8601String(),
      'reminderAnchor': reminderAnchor.name,
      'reminderPrayerName': reminderPrayerName,
      'reminderOffsetMinutes': reminderOffsetMinutes,
      'reminderAnchorDate': reminderAnchorDate?.toIso8601String(),
      'reminderRepeatCount': reminderRepeatCount,
      'reminderWeekdays': reminderWeekdays.join(','),
      'reminderDayOfMonth': reminderDayOfMonth,
      'reminderYearlyDate': reminderYearlyDate?.toIso8601String(),
    };
  }

  factory ItemGroup.fromMap(Map<dynamic, dynamic> map) {
    final rawReminderAt = map['reminderAt']?.toString();
    final anchor = ItemReminderAnchor.fromName(
      map['reminderAnchor']?.toString(),
    );
    final rawAnchorDate = map['reminderAnchorDate']?.toString();
    final reminderAnchorDate = (rawAnchorDate == null || rawAnchorDate.isEmpty)
        ? null
        : DateTime.tryParse(rawAnchorDate);
    final rawYearlyDate = map['reminderYearlyDate']?.toString();
    final reminderYearlyDate =
        (rawYearlyDate == null || rawYearlyDate.isEmpty)
        ? null
        : DateTime.tryParse(rawYearlyDate);
    final reminderWeekdays = (map['reminderWeekdays']?.toString() ?? '')
        .split(',')
        .map((part) => int.tryParse(part.trim()))
        .whereType<int>()
        .where((day) => day >= 1 && day <= 7)
        .toList(growable: false);
    final rawRecurrence = map['reminderRecurrence']?.toString() ??
        map['reminderRepeat']?.toString();
    var recurrence = ReminderRecurrence.fromName(rawRecurrence);
    final parsedReminderAt = (rawReminderAt == null || rawReminderAt.isEmpty)
        ? null
        : DateTime.tryParse(rawReminderAt);
    final isLegacyPrayer = anchor == ItemReminderAnchor.prayerTime &&
        reminderAnchorDate == null &&
        (rawRecurrence == null ||
            rawRecurrence == 'once' ||
            rawRecurrence == 'daily');
    if (isLegacyPrayer && (rawRecurrence == null || rawRecurrence == 'once')) {
      recurrence = ReminderRecurrence.daily;
    }
    final effectiveAnchorDate = reminderAnchorDate ??
        (isLegacyPrayer
            ? null
            : (recurrence != ReminderRecurrence.once
                ? (parsedReminderAt ?? DateTime.now())
                : null));
    return ItemGroup(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      reminderEnabled: (map['reminderEnabled'] as bool?) ?? false,
      reminderRecurrence: recurrence,
      reminderMonthlyBasis: CalendarBasis.fromName(
        map['reminderMonthlyBasis']?.toString(),
      ),
      reminderYearlyBasis: CalendarBasis.fromName(
        map['reminderYearlyBasis']?.toString(),
      ),
      reminderAt: parsedReminderAt,
      reminderAnchor: anchor,
      reminderPrayerName: map['reminderPrayerName']?.toString(),
      reminderOffsetMinutes: (map['reminderOffsetMinutes'] as num?)?.toInt() ?? 0,
      reminderAnchorDate: effectiveAnchorDate,
      reminderRepeatCount: (map['reminderRepeatCount'] as num?)?.toInt(),
      reminderWeekdays: reminderWeekdays,
      reminderDayOfMonth: (map['reminderDayOfMonth'] as num?)?.toInt(),
      reminderYearlyDate: reminderYearlyDate,
    );
  }
}