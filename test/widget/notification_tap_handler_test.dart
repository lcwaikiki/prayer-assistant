import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/screens/hijri_calendar_screen.dart';
import 'package:prayer_assistant/src/navigation.dart';
import 'package:prayer_assistant/src/services/notification_tap_handler.dart';
import 'package:prayer_assistant/src/tesbihat/screens/execution_screen.dart';
import 'package:prayer_assistant/src/tesbihat/screens/group_screen.dart';
import 'package:prayer_assistant/src/tesbihat/state/items_notifier.dart';
import 'package:provider/provider.dart' as provider;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../helpers/fake_flutter_local_notifications_platform.dart';
import '../helpers/test_app.dart';
import '../helpers/test_harness.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_timezone'),
      (call) async => 'UTC',
    );
  });

  testWidgets('routes a tesbih payload to the execution screen', (
    tester,
  ) async {
    final harness = TestHarness.create();
    await harness.initialize();
    await pumpTapHost(tester, harness);

    handleNotificationTap('${tesbihItemPayloadPrefix}item-1');
    await tester.pumpAndSettle();

    expect(find.byType(ExecutionScreen), findsOneWidget);
    expect(find.byType(HijriCalendarScreen), findsNothing);
  });

  testWidgets('routes a calendar payload to the calendar screen', (
    tester,
  ) async {
    final harness = TestHarness.create();
    await harness.initialize();
    await pumpTapHost(tester, harness);

    handleNotificationTap('${calendarReminderPayloadPrefix}reminder-1');
    await tester.pumpAndSettle();

    expect(find.byType(HijriCalendarScreen), findsOneWidget);
    expect(find.byType(ExecutionScreen), findsNothing);
  });

  testWidgets('routes a group payload to the group screen', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();
    await pumpTapHost(tester, harness);

    handleNotificationTap('${tesbihGroupPayloadPrefix}group-1');
    await tester.pumpAndSettle();

    expect(find.byType(GroupScreen), findsOneWidget);
    expect(find.byType(ExecutionScreen), findsNothing);
    expect(find.byType(HijriCalendarScreen), findsNothing);
  });

  testWidgets('routes JSON calendar payload to the calendar screen', (
    tester,
  ) async {
    final harness = TestHarness.create();
    await harness.initialize();
    await pumpTapHost(tester, harness);

    handleNotificationTap('{"type":"calendar","id":"c-1"}');
    await tester.pumpAndSettle();

    expect(find.byType(HijriCalendarScreen), findsOneWidget);
  });

  testWidgets('routes JSON tesbih item payload to the execution screen', (
    tester,
  ) async {
    final harness = TestHarness.create();
    await harness.initialize();
    await pumpTapHost(tester, harness);

    handleNotificationTap('{"type":"tesbih_item","id":"item-1"}');
    await tester.pumpAndSettle();

    expect(find.byType(ExecutionScreen), findsOneWidget);
  });

  testWidgets('routes JSON tesbih group payload to the group screen', (
    tester,
  ) async {
    final harness = TestHarness.create();
    await harness.initialize();
    await pumpTapHost(tester, harness);

    handleNotificationTap('{"type":"tesbih_group","id":"group-1"}');
    await tester.pumpAndSettle();

    expect(find.byType(GroupScreen), findsOneWidget);
  });

  testWidgets('ignores payloads without a known feature prefix', (
    tester,
  ) async {
    final harness = TestHarness.create();
    await harness.initialize();
    await pumpTapHost(tester, harness);

    // Prayer notifications carry JSON payloads and must not deep-link.
    handleNotificationTap('{"fireAt":"2026-08-17T12:35:00"}');
    handleNotificationTap('item-1');
    handleNotificationTap(null);
    handleNotificationTap(tesbihItemPayloadPrefix);
    handleNotificationTap(tesbihGroupPayloadPrefix);
    await tester.pumpAndSettle();

    expect(find.byType(ExecutionScreen), findsNothing);
    expect(find.byType(HijriCalendarScreen), findsNothing);
    expect(find.byType(GroupScreen), findsNothing);
  });

  testWidgets('handleNotificationResponse dismiss cancels notification', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      final fakePlatform = FakeFlutterLocalNotificationsPlatform();
      FlutterLocalNotificationsPlatform.instance = fakePlatform;
      final harness = TestHarness.create();
      await harness.initialize();
      await pumpTapHost(tester, harness);

      await handleNotificationResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          id: 42,
          actionId: notificationActionDismiss,
        ),
      );
      await tester.pumpAndSettle();

      expect(fakePlatform.cancelledIds, contains(42));
      expect(fakePlatform.scheduledIds, isEmpty);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
      'handleNotificationResponse done marks prayer completed for prayer notification',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      final fakePlatform = FakeFlutterLocalNotificationsPlatform();
      FlutterLocalNotificationsPlatform.instance = fakePlatform;
      final harness = TestHarness.create();
      await harness.initialize();
      await pumpTapHost(tester, harness);

      await handleNotificationResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          id: 7,
          actionId: notificationActionDone,
          payload: '{"type":"prayer","prayerKey":"fajr"}',
        ),
      );
      await tester.pumpAndSettle();

      expect(fakePlatform.cancelledIds, contains(7));
      final now = DateTime.now();
      final todayKey =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      expect(harness.controller.prayerCompletions[todayKey], contains('fajr'));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
      'handleNotificationResponse snooze cancels and schedules future reminder',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      final fakePlatform = FakeFlutterLocalNotificationsPlatform();
      FlutterLocalNotificationsPlatform.instance = fakePlatform;
      final harness = TestHarness.create();
      await harness.initialize();
      await pumpTapHost(tester, harness);

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
      await tester.pumpAndSettle();

      expect(fakePlatform.cancelledIds, contains(15));
      expect(fakePlatform.scheduledIds, contains(15));
      expect(fakePlatform.scheduledDates, isNotEmpty);
      final fireTime = fakePlatform.scheduledDates.first;
      expect(fireTime.isAfter(DateTime.now()), isTrue);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
      'handleNotificationResponse body tap routes without cancelling notification',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      final fakePlatform = FakeFlutterLocalNotificationsPlatform();
      FlutterLocalNotificationsPlatform.instance = fakePlatform;
      final harness = TestHarness.create();
      await harness.initialize();
      await pumpTapHost(tester, harness);

      await handleNotificationResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 20,
          actionId: null,
          payload: '{"type":"prayer","prayerKey":"fajr"}',
        ),
      );
      await tester.pumpAndSettle();

      expect(fakePlatform.cancelledIds, isEmpty);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
      'handleNotificationResponse resolves id from payload when response.id is null',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      final fakePlatform = FakeFlutterLocalNotificationsPlatform();
      FlutterLocalNotificationsPlatform.instance = fakePlatform;
      final harness = TestHarness.create();
      await harness.initialize();
      await pumpTapHost(tester, harness);

      await handleNotificationResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          id: null,
          actionId: notificationActionDismiss,
          payload: '{"id":33,"type":"calendar"}',
        ),
      );
      await tester.pumpAndSettle();

      expect(fakePlatform.cancelledIds, contains(33));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

/// Pumps a minimal app whose root navigator uses [rootNavigatorKey], so
/// [handleNotificationTap] can push routes exactly like it does in the
/// real app.
Future<void> pumpTapHost(WidgetTester tester, TestHarness harness) async {
  addTearDown(harness.controller.dispose);
  final app = provider.ChangeNotifierProvider.value(
    value: harness.controller,
    child: ProviderScope(
      overrides: [
        itemRepositoryProvider.overrideWithValue(harness.itemRepository),
        itemHistoryRepositoryProvider.overrideWithValue(
          harness.itemHistoryRepository,
        ),
        itemReminderServiceProvider.overrideWithValue(
          harness.itemReminderService,
        ),
      ],
      child: testLocalizedApp(
        child: const Scaffold(body: SizedBox.shrink()),
        navigatorKey: rootNavigatorKey,
      ),
    ),
  );
  await pumpLocalized(tester, app);
}
