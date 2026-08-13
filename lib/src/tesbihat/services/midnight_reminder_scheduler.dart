import 'dart:io' show Platform;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../services/local_database.dart';
import '../data/item_repository.dart';
import '../models/item.dart';
import 'item_reminder_service.dart';
import 'prayer_anchor_resolver.dart';

const _midnightAlarmId = 5001;

/// Re-resolves and re-schedules every prayer-anchored beads reminder so it
/// tracks the current day's actual prayer times. Runs once daily just after
/// midnight, in its own background isolate — independent of whether the app
/// is open or even running, which a fixed-time notification repeat alone
/// can't do since prayer times shift by a few minutes day to day.
///
/// Android-only: iOS does not allow apps to run code at an arbitrary exact
/// background time at all, so on iOS these reminders simply refresh the
/// next time the app is opened instead.
@pragma('vm:entry-point')
Future<void> midnightReminderRefreshCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final itemsBox = await Hive.openBox<dynamic>('items_box');
  final repository = ItemRepository.hive(itemsBox);
  final reminderService = ItemReminderService();
  await reminderService.initialize();
  final database = LocalDatabase();

  final items = repository.loadItems();
  final updatedItems = <Item>[];
  var changed = false;

  for (final item in items) {
    if (item.reminderEnabled &&
        item.reminderAnchor == ItemReminderAnchor.prayerTime) {
      final resolved = await resolvePrayerAnchoredTime(
        database,
        prayerName: item.reminderPrayerName,
        offsetMinutes: item.reminderOffsetMinutes,
      );
      if (resolved != null) {
        final updated = item.copyWith(reminderAt: resolved);
        updatedItems.add(updated);
        changed = true;
        await reminderService.scheduleReminder(updated);
        continue;
      }
    }
    updatedItems.add(item);
  }

  if (changed) {
    repository.saveItems(updatedItems);
  }
}

class MidnightReminderScheduler {
  /// Arms the daily midnight refresh alarm. Safe to call every app start;
  /// re-registering with the same id just resets the existing alarm. No-op
  /// on platforms other than Android.
  static Future<void> initializeAndSchedule() async {
    if (!Platform.isAndroid) {
      return;
    }
    await AndroidAlarmManager.initialize();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      _midnightAlarmId,
      midnightReminderRefreshCallback,
      startAt: nextMidnight,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }
}
