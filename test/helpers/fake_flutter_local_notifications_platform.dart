import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Test double for FlutterLocalNotificationsPlatform. The plugin routes
/// cancel/zonedSchedule to this instance when the test overrides
/// debugDefaultTargetPlatformOverride to TargetPlatform.linux.
class FakeFlutterLocalNotificationsPlatform
    extends FlutterLocalNotificationsPlatform {
  FakeFlutterLocalNotificationsPlatform();

  final scheduledIds = <int>[];
  final scheduledDates = <tz.TZDateTime>[];
  final scheduledMatches = <DateTimeComponents?>[];
  final scheduledPayloads = <String?>[];
  final scheduledBodies = <String?>[];
  final cancelledIds = <int>[];

  /// When true, every zonedSchedule attempt throws (simulating Android's
  /// scheduled-notification cap).
  bool failSchedules = false;

  /// When true, the first zonedSchedule attempt throws and the retry
  /// succeeds (exercising the exact-to-inexact alarm fallback).
  bool failFirstAttempt = false;

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    if (failSchedules) {
      throw PlatformException(code: 'cap');
    }
    if (failFirstAttempt) {
      failFirstAttempt = false;
      throw PlatformException(code: 'exact');
    }
    scheduledIds.add(id);
    _pendingIds.add(id);
    scheduledDates.add(scheduledDate);
    scheduledMatches.add(matchDateTimeComponents);
    scheduledPayloads.add(payload);
    scheduledBodies.add(body);
  }

  @override
  Future<void> cancel({required int id}) async {
    cancelledIds.add(id);
    _pendingIds.remove(id);
  }

  final _pendingIds = <int>{};

  /// Ids scheduled and not cancelled since, like the real plugin's list.
  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async =>
      [for (final id in _pendingIds) PendingNotificationRequest(id, null, null, null)];

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async => const [];
}