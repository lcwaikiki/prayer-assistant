import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

import '../calendar/screens/hijri_calendar_screen.dart';
import '../controller/prayer_app_controller.dart';
import '../navigation.dart';
import '../tesbihat/screens/execution_screen.dart';
import '../tesbihat/screens/group_screen.dart';
import '../models/prayer_models.dart';
import 'local_database.dart';
import 'native_reminder_service.dart';
import 'notification_strings.dart';
import 'timezone_setup.dart';

/// Action identifiers for interactive notifications.
const notificationActionSnooze = 'action_snooze';
const notificationActionDismiss = 'action_dismiss';
const notificationActionDone = 'action_done';

/// Category identifier for notifications with Snooze/Dismiss/Done actions.
const notificationCategoryReminder = 'reminder_actions';

/// Darwin notification category definitions for iOS/macOS.
final List<DarwinNotificationCategory> darwinReminderCategories = [
  DarwinNotificationCategory(
    notificationCategoryReminder,
    actions: <DarwinNotificationAction>[
      DarwinNotificationAction.plain(
        notificationActionSnooze,
        'Snooze',
      ),
      DarwinNotificationAction.plain(
        notificationActionDismiss,
        'Dismiss',
        options: <DarwinNotificationActionOption>{
          DarwinNotificationActionOption.destructive,
        },
      ),
      DarwinNotificationAction.plain(
        notificationActionDone,
        'Done',
      ),
    ],
  ),
];

/// Payload prefixes identifying which feature scheduled a notification.
/// All three notification producers funnel taps through a single
/// platform-level handler, so the payload itself must carry the feature.
/// Prayer notifications use JSON payloads and never deep-link.
const calendarReminderPayloadPrefix = 'calendar_reminder:';
const tesbihItemPayloadPrefix = 'tesbih_item:';
const tesbihGroupPayloadPrefix = 'tesbih_group:';

/// Top-level background notification response handler.
@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse response) async {
  await handleNotificationResponse(response);
}

/// Handles notification responses including action clicks (Snooze, Dismiss, Done)
/// and normal body taps.
Future<void> handleNotificationResponse(NotificationResponse response) async {
  final actionId = response.actionId;

  if (actionId == null || actionId.isEmpty) {
    handleNotificationTap(response.payload);
    return;
  }

  final plugin = FlutterLocalNotificationsPlugin();
  var notificationId = response.id;
  final payload = response.payload;
  if (notificationId == null && payload != null && payload.isNotEmpty) {
    try {
      var raw = payload;
      if (raw.startsWith(calendarReminderPayloadPrefix)) {
        raw = raw.substring(calendarReminderPayloadPrefix.length);
      } else if (raw.startsWith(tesbihItemPayloadPrefix)) {
        raw = raw.substring(tesbihItemPayloadPrefix.length);
      } else if (raw.startsWith(tesbihGroupPayloadPrefix)) {
        raw = raw.substring(tesbihGroupPayloadPrefix.length);
      }
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final rawId = map['id'];
      if (rawId is int) {
        notificationId = rawId;
      } else if (rawId is String) {
        notificationId = int.tryParse(rawId);
      }
    } catch (_) {}
  }
  if (notificationId != null) {
    try {
      await plugin.cancel(id: notificationId);
    } catch (_) {}
    try {
      await NativeReminderService.cancel(notificationId);
    } catch (_) {}
  }

  if (actionId == notificationActionDismiss) {
    return;
  }

  if (actionId == notificationActionDone) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      try {
        final map = jsonDecode(payload) as Map<String, dynamic>;
        final prayerKey = map['prayerKey'] as String?;
        if (prayerKey != null && prayerKey.isNotEmpty) {
          await _markPrayerCompleted(prayerKey);
        }
      } catch (_) {}
    }
    return;
  }

  if (actionId == notificationActionSnooze) {
    await _handleSnooze(response, plugin);
    return;
  }
}

Future<void> _markPrayerCompleted(String prayerKey) async {
  final context = rootNavigatorKey.currentContext;
  if (context != null) {
    try {
      context.read<PrayerAppController>().markPrayerCompleted(prayerKey);
      return;
    } catch (_) {}
  }

  final db = LocalDatabase();
  final completions = await db.loadPrayerCompletions();
  final now = DateTime.now();
  final dateKey = '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
  final next = Map<String, List<String>>.from(completions);
  final current = List<String>.from(next[dateKey] ?? []);
  if (!current.any((p) => p.toLowerCase() == prayerKey.toLowerCase())) {
    current.add(prayerKey);
    next[dateKey] = current;
    await db.savePrayerCompletions(next);
  }
}

Future<void> _handleSnooze(
  NotificationResponse response,
  FlutterLocalNotificationsPlugin plugin,
) async {
  int snoozeMinutes = 10;
  Locale? locale;
  final context = rootNavigatorKey.currentContext;
  if (context != null) {
    try {
      final controller = context.read<PrayerAppController>();
      snoozeMinutes = controller.snoozeDurationMinutes;
      final pref = controller.localePreference;
      if (pref != AppLocalePreference.system) {
        locale = Locale(pref.name);
      }
    } catch (_) {}
  } else {
    try {
      final db = LocalDatabase();
      snoozeMinutes = await db.loadSnoozeDurationMinutes();
      final localePref = await db.loadLocalePreference();
      if (localePref != null && localePref.isNotEmpty && localePref != 'system') {
        locale = Locale(localePref);
      }
    } catch (_) {}
  }

  try {
    tz.TZDateTime.now(tz.local);
  } catch (_) {
    await initializeLocalTimezone();
  }
  final scheduledDate = tz.TZDateTime.now(tz.local).add(
    Duration(minutes: snoozeMinutes),
  );

  String title = 'Reminder';
  String body = '';
  String channelId = 'prayer_reminders_chime_vibrate_sound';
  String channelName = 'Prayer Reminders (vibrate + sound)';
  String? soundResource = 'reminder_chime';

  final payload = response.payload;
  if (payload != null && payload.isNotEmpty) {
    try {
      var jsonStr = payload;
      if (jsonStr.startsWith(calendarReminderPayloadPrefix)) {
        jsonStr = jsonStr.substring(calendarReminderPayloadPrefix.length);
        channelId = 'calendar_reminders_chime';
        channelName = 'Calendar Reminders';
      } else if (jsonStr.startsWith(tesbihItemPayloadPrefix) ||
          jsonStr.startsWith(tesbihGroupPayloadPrefix)) {
        jsonStr = jsonStr.substring(
          jsonStr.startsWith(tesbihItemPayloadPrefix)
              ? tesbihItemPayloadPrefix.length
              : tesbihGroupPayloadPrefix.length,
        );
        channelId = 'tesbih_reminders_chime';
        channelName = 'Tasbih Reminders';
      }
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      title = map['title'] as String? ?? title;
      body = map['body'] as String? ?? body;
      channelId = map['channelId'] as String? ?? channelId;
      channelName = map['channelName'] as String? ?? channelName;
      soundResource = map['soundResource'] as String? ?? soundResource;
      if (map['type'] == 'calendar') {
        channelId = 'calendar_reminders_chime';
        channelName = 'Calendar Reminders';
      } else if (map['type'] == 'tesbih_item' || map['type'] == 'tesbih_group') {
        channelId = 'tesbih_reminders_chime';
        channelName = 'Tasbih Reminders';
      }
    } catch (_) {
      if (payload.startsWith(calendarReminderPayloadPrefix)) {
        channelId = 'calendar_reminders_chime';
        channelName = 'Calendar Reminders';
      } else if (payload.startsWith(tesbihItemPayloadPrefix) ||
          payload.startsWith(tesbihGroupPayloadPrefix)) {
        channelId = 'tesbih_reminders_chime';
        channelName = 'Tasbih Reminders';
      }
    }
  }
  final strings = NotificationStrings.of(locale);

  final details = NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: false,
      ongoing: true,
      additionalFlags: Int32List.fromList(const <int>[32]),
      sound: soundResource != null
          ? RawResourceAndroidNotificationSound(soundResource)
          : null,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          notificationActionSnooze,
          strings.snooze,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          notificationActionDismiss,
          strings.dismiss,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          notificationActionDone,
          strings.done,
          cancelNotification: true,
        ),
      ],
    ),
    iOS: const DarwinNotificationDetails(
      categoryIdentifier: notificationCategoryReminder,
    ),
  );

  int id = response.id ?? 900000;
  if (response.id == null && payload != null && payload.isNotEmpty) {
    try {
      var raw = payload;
      if (raw.startsWith(calendarReminderPayloadPrefix)) {
        raw = raw.substring(calendarReminderPayloadPrefix.length);
      } else if (raw.startsWith(tesbihItemPayloadPrefix)) {
        raw = raw.substring(tesbihItemPayloadPrefix.length);
      } else if (raw.startsWith(tesbihGroupPayloadPrefix)) {
        raw = raw.substring(tesbihGroupPayloadPrefix.length);
      }
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final rawId = map['id'];
      if (rawId is int) {
        id = rawId;
      } else if (rawId is String) {
        id = int.tryParse(rawId) ?? id;
      }
    } catch (_) {}
  }
  if (NativeReminderService.isAndroid) {
    await NativeReminderService.schedule(
      id: id,
      triggerAt: scheduledDate,
      title: title,
      body: body,
      payload: payload,
      snoozeLabel: strings.snooze,
      dismissLabel: strings.dismiss,
      doneLabel: strings.done,
      soundResource: soundResource,
    );
    return;
  }
  try {
    await plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  } catch (_) {
    await plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }
}

/// Routes a notification tap to the matching screen based on the
/// payload's feature prefix or JSON type. Registered by every service that calls
/// `FlutterLocalNotificationsPlugin.initialize`.
void handleNotificationTap(String? payload) {
  if (payload == null || payload.isEmpty) {
    return;
  }

  // Handle JSON payloads
  if (payload.startsWith('{')) {
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final type = map['type'] as String?;
      final id = map['id'] as String? ?? '';
      if (type == 'calendar') {
        rootNavigatorKey.currentState?.push(
          MaterialPageRoute<void>(
            builder: (_) => HijriCalendarScreen(
              initialDate: DateTime.now(),
              openDetailOnLaunch: true,
            ),
          ),
        );
        return;
      } else if (type == 'tesbih_item') {
        if (id.isEmpty) return;
        _navigateToTesbihItem(id);
        return;
      } else if (type == 'tesbih_group') {
        if (id.isEmpty) return;
        _navigateToTesbihGroup(id);
        return;
      }
      return;
    } catch (_) {}
  }

  // Handle prefix-based string payloads
  if (payload.startsWith(calendarReminderPayloadPrefix)) {
    if (payload.length == calendarReminderPayloadPrefix.length) {
      return;
    }
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => HijriCalendarScreen(
          initialDate: DateTime.now(),
          openDetailOnLaunch: true,
        ),
      ),
    );
  } else if (payload.startsWith(tesbihItemPayloadPrefix)) {
    var itemId = payload.substring(tesbihItemPayloadPrefix.length);
    if (itemId.isEmpty) {
      return;
    }
    if (itemId.startsWith('{')) {
      try {
        final map = jsonDecode(itemId) as Map<String, dynamic>;
        itemId = map['id'] as String? ?? itemId;
      } catch (_) {}
    }
    _navigateToTesbihItem(itemId);
  } else if (payload.startsWith(tesbihGroupPayloadPrefix)) {
    var groupId = payload.substring(tesbihGroupPayloadPrefix.length);
    if (groupId.isEmpty) {
      return;
    }
    if (groupId.startsWith('{')) {
      try {
        final map = jsonDecode(groupId) as Map<String, dynamic>;
        groupId = map['id'] as String? ?? groupId;
      } catch (_) {}
    }
    _navigateToTesbihGroup(groupId);
  }
}

void _navigateToTesbihItem(String itemId) {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final context = rootNavigatorKey.currentContext;
  if (context != null) {
    try {
      context.read<PrayerAppController>().setTab(4);
    } catch (_) {}
  }
  rootNavigatorKey.currentState?.push(
    MaterialPageRoute<void>(builder: (_) => ExecutionScreen(itemId: itemId)),
  );
}

void _navigateToTesbihGroup(String groupId) {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final context = rootNavigatorKey.currentContext;
  if (context != null) {
    try {
      context.read<PrayerAppController>().setTab(4);
    } catch (_) {}
  }
  rootNavigatorKey.currentState?.push(
    MaterialPageRoute<void>(builder: (_) => GroupScreen(groupId: groupId)),
  );
}

/// Handles the case where tapping a notification is what launched the app
/// from fully killed. Call once after the first frame so the root
/// navigator exists to push onto.
Future<void> handleAppLaunchFromNotification() async {
  final details = await FlutterLocalNotificationsPlugin()
      .getNotificationAppLaunchDetails();
  if (details?.didNotificationLaunchApp == true &&
      details?.notificationResponse != null) {
    await handleNotificationResponse(details!.notificationResponse!);
  }
}
