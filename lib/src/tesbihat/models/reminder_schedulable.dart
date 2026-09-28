import '../../calendar/models/calendar_reminder.dart';
import 'item.dart';
import 'item_group.dart';

/// The reminder options shared by beads ([Item]) and groups
/// ([ItemGroup]), so the reminder service can schedule both with one code
/// path.
abstract interface class ReminderSchedulable {
  String get id;
  String get title;
  bool get reminderEnabled;
  ReminderRecurrence get reminderRecurrence;
  CalendarBasis get reminderMonthlyBasis;
  CalendarBasis get reminderYearlyBasis;
  DateTime? get reminderAt;
  ItemReminderAnchor get reminderAnchor;
  String? get reminderPrayerName;
  int get reminderOffsetMinutes;
  DateTime? get reminderAnchorDate;
  int? get reminderRepeatCount;
  List<int> get reminderWeekdays;
  int? get reminderDayOfMonth;
  DateTime? get reminderYearlyDate;
  bool get isTask;
}

extension ReminderSchedulableX on ReminderSchedulable {
  CalendarReminder toCalendarReminder() {
    return CalendarReminder(
      id: id,
      title: title,
      notes: '',
      anchorAt: reminderAt ?? reminderAnchorDate ?? DateTime.now(),
      recurrence: reminderRecurrence,
      monthlyBasis: reminderMonthlyBasis,
      yearlyBasis: reminderYearlyBasis,
      anchor: reminderAnchor == ItemReminderAnchor.prayerTime
          ? CalendarReminderAnchor.prayerTime
          : CalendarReminderAnchor.clockTime,
      anchorPrayerName: reminderPrayerName,
      anchorOffsetMinutes: reminderOffsetMinutes,
      anchorDate: reminderAnchorDate,
      enabled: reminderEnabled,
      repeatCount: reminderRepeatCount,
      weekdays: reminderWeekdays,
      dayOfMonth: reminderDayOfMonth,
      yearlyDate: reminderYearlyDate,
      isTask: isTask,
    );
  }

  bool occursOn(DateTime date) {
    if (!reminderEnabled) return false;
    return toCalendarReminder().occursOn(date);
  }
}

enum TaskItemType { calendarReminder, bead, group }

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.type,
    required this.occursOnDate,
    this.targetId,
    this.targetCount,
    this.bead,
    this.group,
    this.reminder,
  });

  final String id;
  final String title;
  final TaskItemType type;
  final bool Function(DateTime date) occursOnDate;
  final String? targetId;
  final int? targetCount;
  final Item? bead;
  final ItemGroup? group;
  final CalendarReminder? reminder;
  CalendarReminder? get calendarReminder => reminder;

  int? get timeMinutes {
    if (reminder != null) {
      return reminder!.anchorAt.hour * 60 + reminder!.anchorAt.minute;
    }
    if (bead?.reminderAt != null) {
      return bead!.reminderAt!.hour * 60 + bead!.reminderAt!.minute;
    }
    if (group?.reminderAt != null) {
      return group!.reminderAt!.hour * 60 + group!.reminderAt!.minute;
    }
    return null;
  }

  bool occursOn(DateTime date) => occursOnDate(date);
}