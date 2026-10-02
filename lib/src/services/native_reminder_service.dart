import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_tap_handler.dart';

class NativeReminderService {
  static const MethodChannel _channel =
      MethodChannel('prayer_assistant/native_reminders');

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    String snoozeLabel = 'Snooze',
    String dismissLabel = 'Dismiss',
    String doneLabel = 'Done',
    bool showDone = false,
    String? soundResource = 'reminder_chime',
    String? originalTime,
    bool dismissConfirm = true,
  }) async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('show', {
        'id': id,
        'title': title,
        'body': body,
        'payload': payload,
        'snoozeLabel': snoozeLabel,
        'dismissLabel': dismissLabel,
        'doneLabel': doneLabel,
        'showDone': showDone,
        'soundResource': soundResource,
        'originalTime': originalTime,
        'dismissConfirm': dismissConfirm,
      });
    } catch (_) {}
  }

  static Future<void> schedule({
    required int id,
    required DateTime triggerAt,
    required String title,
    required String body,
    String? payload,
    String snoozeLabel = 'Snooze',
    String dismissLabel = 'Dismiss',
    String doneLabel = 'Done',
    bool showDone = false,
    String? soundResource = 'reminder_chime',
    String? originalTime,
    bool dismissConfirm = true,
  }) async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('schedule', {
        'id': id,
        'triggerAtMillis': triggerAt.millisecondsSinceEpoch,
        'title': title,
        'body': body,
        'payload': payload,
        'snoozeLabel': snoozeLabel,
        'dismissLabel': dismissLabel,
        'doneLabel': doneLabel,
        'showDone': showDone,
        'soundResource': soundResource,
        'originalTime': originalTime,
        'dismissConfirm': dismissConfirm,
      });
    } catch (_) {}
  }

  static Future<void> cancel(int id) async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('cancel', {'id': id});
    } catch (_) {}
  }

  static Future<void> updateDismissConfirm(bool enabled) async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('updateDismissConfirm', {
        'dismissConfirm': enabled,
      });
    } catch (_) {}
  }

  static void initializeNotificationTapHandler(
    void Function(String? payload) onNotificationTap, {
    void Function(NotificationResponse response)? onNotificationResponse,
  }) {
    if (!isAndroid) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNotificationTap') {
        final dynamic args = call.arguments;
        String? payload;
        if (args is Map) {
          payload = args['payload'] as String?;
        } else if (args is String) {
          payload = args;
        }
        if (payload != null && payload.isNotEmpty) {
          onNotificationTap(payload);
        }
      } else if (call.method == 'onNotificationAction') {
        final dynamic args = call.arguments;
        if (args is Map) {
          final actionId = args['actionId'] as String?;
          final payload = args['payload'] as String?;
          final id = args['id'] as int?;
          final response = NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
            actionId: actionId,
            payload: payload,
            id: id,
          );
          if (onNotificationResponse != null) {
            onNotificationResponse(response);
          } else {
            await handleNotificationResponse(response);
          }
        }
      }
    });
  }

  static Future<String?> getInitialPayload() async {
    if (!isAndroid) return null;
    try {
      final dynamic res = await _channel.invokeMethod<dynamic>('getInitialPayload');
      if (res is Map) {
        return res['payload'] as String?;
      } else if (res is String) {
        return res;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
