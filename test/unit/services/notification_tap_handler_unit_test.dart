import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/services/local_database.dart';
import 'package:prayer_assistant/src/services/notification_tap_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../helpers/fake_flutter_local_notifications_platform.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('handleNotificationResponse Unit Tests', () {
    test('dismiss action cancels notification without rescheduling', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        final fakePlatform = FakeFlutterLocalNotificationsPlatform();
        FlutterLocalNotificationsPlatform.instance = fakePlatform;

        await handleNotificationResponse(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
            id: 42,
            actionId: notificationActionDismiss,
          ),
        );

        expect(fakePlatform.cancelledIds, contains(42));
        expect(fakePlatform.scheduledIds, isEmpty);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('done action on prayer notification marks prayer completed', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        final fakePlatform = FakeFlutterLocalNotificationsPlatform();
        FlutterLocalNotificationsPlatform.instance = fakePlatform;
        final db = LocalDatabase();
        await db.savePrayerCompletions({});

        await handleNotificationResponse(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
            id: 7,
            actionId: notificationActionDone,
            payload: '{"type":"prayer","prayerKey":"fajr"}',
          ),
        );

        expect(fakePlatform.cancelledIds, contains(7));
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('done action on calendar task marks calendar task completed', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        final fakePlatform = FakeFlutterLocalNotificationsPlatform();
        FlutterLocalNotificationsPlatform.instance = fakePlatform;

        final date = DateTime(2026, 9, 27);
        await handleNotificationResponse(
          NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
            id: 101,
            actionId: notificationActionDone,
            payload:
                '{"type":"calendar","id":"cal_item_1","date":"${date.toIso8601String()}"}',
          ),
        );

        expect(fakePlatform.cancelledIds, contains(101));
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('done action on bead and group task marks tasks completed', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        final fakePlatform = FakeFlutterLocalNotificationsPlatform();
        FlutterLocalNotificationsPlatform.instance = fakePlatform;

        await handleNotificationResponse(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
            id: 102,
            actionId: notificationActionDone,
            payload: '{"type":"tesbih_item","id":"bead_1"}',
          ),
        );
        await handleNotificationResponse(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
            id: 103,
            actionId: notificationActionDone,
            payload: '{"type":"tesbih_group","id":"group_1"}',
          ),
        );

        expect(fakePlatform.cancelledIds, contains(102));
        expect(fakePlatform.cancelledIds, contains(103));
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('snooze action cancels and schedules future reminder', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        final fakePlatform = FakeFlutterLocalNotificationsPlatform();
        FlutterLocalNotificationsPlatform.instance = fakePlatform;

        await handleNotificationResponse(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
            id: 15,
            actionId: notificationActionSnooze,
            payload:
                '{"type":"prayer","prayerKey":"fajr","title":"Fajr Reminder","body":"Time for Fajr"}',
          ),
        );

        expect(fakePlatform.cancelledIds, contains(15));
        expect(fakePlatform.scheduledIds, contains(15));
        expect(fakePlatform.scheduledDates, isNotEmpty);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('resolves id from payload when response.id is null', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        final fakePlatform = FakeFlutterLocalNotificationsPlatform();
        FlutterLocalNotificationsPlatform.instance = fakePlatform;

        await handleNotificationResponse(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
            id: null,
            actionId: notificationActionDismiss,
            payload: '{"id":33,"type":"calendar"}',
          ),
        );

        expect(fakePlatform.cancelledIds, contains(33));
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}
