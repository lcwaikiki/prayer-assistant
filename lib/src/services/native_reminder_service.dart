import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
    String? soundResource = 'reminder_chime',
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
        'soundResource': soundResource,
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
    String? soundResource = 'reminder_chime',
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
        'soundResource': soundResource,
      });
    } catch (_) {}
  }

  static Future<void> cancel(int id) async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('cancel', {'id': id});
    } catch (_) {}
  }
}
