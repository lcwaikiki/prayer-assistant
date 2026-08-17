import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../calendar/screens/hijri_calendar_screen.dart';
import '../navigation.dart';
import '../tesbihat/screens/execution_screen.dart';

/// Payload prefixes identifying which feature scheduled a notification.
/// All three notification producers funnel taps through a single
/// platform-level handler, so the payload itself must carry the feature.
/// Prayer notifications use JSON payloads and never deep-link.
const calendarReminderPayloadPrefix = 'calendar_reminder:';
const tesbihItemPayloadPrefix = 'tesbih_item:';

/// Routes a notification tap to the matching screen based on the
/// payload's feature prefix. Registered by every service that calls
/// `FlutterLocalNotificationsPlugin.initialize`, since they share one
/// platform channel and the last registration would otherwise silently
/// win over the others.
void handleNotificationTap(String? payload) {
  if (payload == null || payload.isEmpty) {
    return;
  }
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
    final itemId = payload.substring(tesbihItemPayloadPrefix.length);
    if (itemId.isEmpty) {
      return;
    }
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (_) => ExecutionScreen(itemId: itemId)),
    );
  }
}

/// Handles the case where tapping a notification is what launched the app
/// from fully killed. Call once after the first frame so the root
/// navigator exists to push onto.
Future<void> handleAppLaunchFromNotification() async {
  final details = await FlutterLocalNotificationsPlugin()
      .getNotificationAppLaunchDetails();
  if (details?.didNotificationLaunchApp == true) {
    handleNotificationTap(details!.notificationResponse?.payload);
  }
}
