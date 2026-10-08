import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/calendar/screens/hijri_calendar_screen.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/item_group.dart';
import 'package:prayer_assistant/src/tesbihat/screens/execution_screen.dart';
import 'package:prayer_assistant/src/tesbihat/screens/group_screen.dart';
import 'package:prayer_assistant/src/ui/widgets/upcoming_reminders_card.dart';

import '../helpers/test_harness.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_timezone'),
      (call) async => 'UTC',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('wakelock_plus'),
      (call) async => true,
    );
  });

  testWidgets('tapping calendar item opens HijriCalendarScreen', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    final entries = [
      UpcomingReminder(
        id: 'cal-1',
        title: 'Read Quran',
        next: DateTime(2026, 8, 17, 14, 0),
        type: UpcomingReminderType.calendar,
        calendarReminder: CalendarReminder(
          id: 'cal-1',
          title: 'Read Quran',
          anchorAt: DateTime(2026, 8, 17, 14, 0),
          recurrence: ReminderRecurrence.once,
        ),
      ),
    ];

    await pumpWithHarness(
      tester,
      harness,
      Scaffold(body: UpcomingRemindersCard(entries: entries)),
    );
    expect(find.text('Read Quran'), findsOneWidget);

    await tester.tap(find.text('Read Quran'));
    await tester.pumpAndSettle();
    expect(find.byType(HijriCalendarScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping bead item opens ExecutionScreen', (tester) async {
    final harness = TestHarness.create();
    const beadItem = Item(
      id: 'bead-1',
      title: 'SubhanAllah Bead',
      count: 100,
      check: 33,
      setCount: 1,
      vibrationIntensity: 1,
    );
    harness.itemRepository.saveItems([beadItem]);
    await harness.initialize();

    final entries = [
      UpcomingReminder(
        id: 'bead-1',
        title: 'SubhanAllah Bead',
        next: DateTime(2026, 8, 17, 15, 0),
        type: UpcomingReminderType.bead,
        bead: beadItem,
      ),
    ];

    await pumpWithHarness(
      tester,
      harness,
      Scaffold(body: UpcomingRemindersCard(entries: entries)),
    );
    expect(find.text('SubhanAllah Bead'), findsOneWidget);

    await tester.tap(find.text('SubhanAllah Bead'));
    await tester.pumpAndSettle();
    expect(find.byType(ExecutionScreen), findsOneWidget);
    expect(harness.controller.tabIndex, equals(4));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping group item opens GroupScreen', (tester) async {
    final harness = TestHarness.create();
    const testGroup = ItemGroup(
      id: 'group-1',
      title: 'Morning Dhikr Group',
    );
    harness.itemRepository.saveGroups([testGroup]);
    await harness.initialize();

    final entries = [
      UpcomingReminder(
        id: 'group-1',
        title: 'Morning Dhikr Group',
        next: DateTime(2026, 8, 17, 16, 0),
        type: UpcomingReminderType.group,
        group: testGroup,
      ),
    ];

    await pumpWithHarness(
      tester,
      harness,
      Scaffold(body: UpcomingRemindersCard(entries: entries)),
    );
    expect(find.text('Morning Dhikr Group'), findsOneWidget);

    await tester.tap(find.text('Morning Dhikr Group'));
    await tester.pumpAndSettle();
    expect(find.byType(GroupScreen), findsOneWidget);
    expect(harness.controller.tabIndex, equals(4));

    await tester.pumpWidget(const SizedBox());
  });
}
