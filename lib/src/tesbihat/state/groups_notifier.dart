import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/models/calendar_reminder.dart';
import '../data/item_repository.dart';
import '../models/item.dart';
import '../models/item_group.dart';
import '../services/item_reminder_service.dart';
import 'items_notifier.dart';

final groupsNotifierProvider = NotifierProvider<GroupsNotifier, List<ItemGroup>>(
  GroupsNotifier.new,
);

class GroupsNotifier extends Notifier<List<ItemGroup>> {
  late final ItemRepository _repository;
  late final ItemReminderService _reminderService;

  @override
  List<ItemGroup> build() {
    _repository = ref.watch(itemRepositoryProvider);
    _reminderService = ref.watch(itemReminderServiceProvider);
    return _repository.loadGroups();
  }

  void addGroup({
    required String title,
    bool reminderEnabled = false,
    ItemReminderAnchor reminderAnchor = ItemReminderAnchor.clockTime,
    ReminderRecurrence reminderRecurrence = ReminderRecurrence.once,
    CalendarBasis reminderMonthlyBasis = CalendarBasis.gregorian,
    CalendarBasis reminderYearlyBasis = CalendarBasis.gregorian,
    DateTime? reminderAt,
    DateTime? reminderAnchorDate,
    String? reminderPrayerName,
    int reminderOffsetMinutes = 0,
    int? reminderRepeatCount,
    List<int> reminderWeekdays = const [],
    int? reminderDayOfMonth,
    DateTime? reminderYearlyDate,
  }) {
    final newGroup = ItemGroup(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      reminderEnabled: reminderEnabled,
      reminderAnchor: reminderAnchor,
      reminderRecurrence: reminderRecurrence,
      reminderMonthlyBasis: reminderMonthlyBasis,
      reminderYearlyBasis: reminderYearlyBasis,
      reminderAt: reminderAt,
      reminderAnchorDate: reminderAnchorDate,
      reminderPrayerName: reminderPrayerName,
      reminderOffsetMinutes: reminderOffsetMinutes,
      reminderRepeatCount: reminderRepeatCount,
      reminderWeekdays: reminderWeekdays,
      reminderDayOfMonth: reminderDayOfMonth,
      reminderYearlyDate: reminderYearlyDate,
    );
    state = [...state, newGroup];
    _repository.saveGroups(state);
    _reminderService.scheduleGroupReminder(newGroup);
  }

  void updateGroup(ItemGroup updatedGroup) {
    state = [
      for (final group in state)
        if (group.id == updatedGroup.id) updatedGroup else group,
    ];
    _repository.saveGroups(state);
    _reminderService.scheduleGroupReminder(updatedGroup);
  }

  void deleteGroup(String id) {
    state = state.where((group) => group.id != id).toList(growable: false);
    _repository.saveGroups(state);
    _reminderService.cancelReminder(id);
  }

  void restoreGroup(ItemGroup group, {required int index}) {
    if (state.any((existing) => existing.id == group.id)) {
      return;
    }
    final safeIndex = index.clamp(0, state.length).toInt();
    final nextState = [...state];
    nextState.insert(safeIndex, group);
    state = nextState;
    _repository.saveGroups(state);
    _reminderService.scheduleGroupReminder(group);
  }
}