import '../../calendar/models/calendar_reminder.dart';
import 'item.dart';

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
}