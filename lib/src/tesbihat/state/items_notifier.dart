import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/models/calendar_reminder.dart';
import '../data/item_history_repository.dart';
import '../data/item_repository.dart';
import '../models/daily_item_stat.dart';
import '../models/item.dart';
import '../services/item_reminder_service.dart';

enum TapFeedback { none, standard, checkpoint }

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  throw UnimplementedError('itemRepositoryProvider must be overridden');
});

final itemHistoryRepositoryProvider = Provider<ItemHistoryRepository>((ref) {
  throw UnimplementedError('itemHistoryRepositoryProvider must be overridden');
});

final itemReminderServiceProvider = Provider<ItemReminderService>((ref) {
  throw UnimplementedError('itemReminderServiceProvider must be overridden');
});

final itemsNotifierProvider = NotifierProvider<ItemsNotifier, List<Item>>(
  ItemsNotifier.new,
);

class ItemsNotifier extends Notifier<List<Item>> {
  late final ItemRepository _repository;
  late final ItemHistoryRepository _historyRepository;
  late final ItemReminderService _reminderService;

  @override
  List<Item> build() {
    _repository = ref.watch(itemRepositoryProvider);
    _historyRepository = ref.watch(itemHistoryRepositoryProvider);
    _reminderService = ref.watch(itemReminderServiceProvider);
    return _repository.loadItems();
  }

  List<DailyItemStat> get dailyStats => _historyRepository.loadStats();

  void addItem({
    required String title,
    required String notes,
    required int count,
    required int check,
    required int vibrationIntensity,
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
    final newItem = Item(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      notes: notes,
      count: count,
      check: check,
      setCount: 0,
      vibrationIntensity: vibrationIntensity,
      currentProgress: 0,
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
    state = [...state, newItem];
    _repository.saveItems(state);
    _reminderService.scheduleReminder(newItem);
  }

  void updateItem(Item updatedItem) {
    state = [
      for (final item in state)
        if (item.id == updatedItem.id) updatedItem else item,
    ];
    _repository.saveItems(state);
    _reminderService.scheduleReminder(updatedItem);
  }

  void deleteItem(String id) {
    state = state.where((item) => item.id != id).toList(growable: false);
    _repository.saveItems(state);
    _reminderService.cancelReminder(id);
  }

  void restoreItem(Item item, {required int index}) {
    if (state.any((existing) => existing.id == item.id)) {
      return;
    }

    final safeIndex = index.clamp(0, state.length).toInt();
    final nextState = [...state];
    nextState.insert(safeIndex, item);
    state = nextState;
    _repository.saveItems(state);
    _reminderService.scheduleReminder(item);
  }

  void reorderItems(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) {
      return;
    }
    if (newIndex < 0 || newIndex > state.length) {
      return;
    }

    final nextState = [...state];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final movedItem = nextState.removeAt(oldIndex);
    nextState.insert(newIndex, movedItem);
    state = nextState;
    _repository.saveItems(state);
  }

  TapFeedback incrementProgress(String id) {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) {
      return TapFeedback.none;
    }

    final item = state[index];
    if (item.currentProgress >= item.count) {
      return TapFeedback.none;
    }

    final nextProgress = item.currentProgress + 1;
    final reachedMax = nextProgress == item.count;
    final updated = item.copyWith(
      currentProgress: nextProgress,
      setCount: reachedMax ? item.setCount + 1 : item.setCount,
    );
    final nextState = [...state];
    nextState[index] = updated;
    state = nextState;
    _repository.saveItems(state);
    _historyRepository.addCount(id, _dayKey(DateTime.now()), 1);

    if (Item.isCheckpointProgress(
      currentProgress: updated.currentProgress,
      check: updated.check,
    )) {
      return TapFeedback.checkpoint;
    }
    return TapFeedback.standard;
  }

  void resetProgress(String id) {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    final nextState = [...state];
    nextState[index] = nextState[index].copyWith(currentProgress: 0);
    state = nextState;
    _repository.saveItems(state);
  }

  void setProgress(String id, int progress) {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    final item = state[index];
    final safeProgress = progress.clamp(0, item.count).toInt();
    final nextState = [...state];
    nextState[index] = item.copyWith(currentProgress: safeProgress);
    state = nextState;
    _repository.saveItems(state);
  }

  String? updateProgressAndSetCount({
    required String id,
    required int progress,
    required int setCount,
  }) {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) {
      return 'Item not found';
    }
    final item = state[index];
    if (progress < 0 || progress > item.count) {
      return 'Progress must be between 0 and ${item.count}';
    }
    if (setCount < 0) {
      return 'Set count cannot be negative';
    }

    final nextState = [...state];
    nextState[index] = item.copyWith(
      currentProgress: progress,
      setCount: setCount,
    );
    state = nextState;
    _repository.saveItems(state);
    return null;
  }

  static String _dayKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
