import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/screens/hijri_calendar_screen.dart';
import 'package:prayer_assistant/src/navigation.dart';
import 'package:prayer_assistant/src/services/notification_tap_handler.dart';
import 'package:prayer_assistant/src/tesbihat/screens/execution_screen.dart';
import 'package:prayer_assistant/src/tesbihat/state/items_notifier.dart';
import 'package:provider/provider.dart' as provider;

import '../helpers/test_app.dart';
import '../helpers/test_harness.dart';

void main() {
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
    await tester.pumpAndSettle();

    expect(find.byType(ExecutionScreen), findsNothing);
    expect(find.byType(HijriCalendarScreen), findsNothing);
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
