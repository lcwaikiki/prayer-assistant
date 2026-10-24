import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'native_reminder_service.dart';

/// Cancels every notification in the id window `[base, base + count)`.
///
/// Only ids the plugin actually has pending or shown are cancelled, and the
/// native alarms are cleared in one platform call. Cancelling the whole
/// window id by id costs hundreds of platform calls per reminder.
Future<void> cancelNotificationWindow(
  FlutterLocalNotificationsPlugin plugin,
  int base,
  int count, {
  bool cancelActive = true,
}) async {
  bool inWindow(int? id) => id != null && id >= base && id < base + count;
  final pending = await plugin.pendingNotificationRequests();
  final ids = {
    ...pending.map((r) => r.id).where(inWindow),
    if (cancelActive)
      ...((await plugin.getActiveNotifications())
          .map((n) => n.id)
          .where(inWindow)),
  };
  await Future.wait([
    for (final id in ids) plugin.cancel(id: id!),
    NativeReminderService.cancelRange(base, count, cancelActive: cancelActive),
  ]);
}
