import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/calendar/screens/calendar_reminder_form_screen.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/item_group.dart';
import 'package:prayer_assistant/src/tesbihat/screens/group_form_screen.dart';
import 'package:prayer_assistant/src/tesbihat/screens/item_form_screen.dart';
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

  testWidgets('tapping calendar item opens CalendarReminderFormScreen in read-only mode', (tester) async {
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
    expect(find.byType(CalendarReminderFormScreen), findsOneWidget);
    final form = tester.widget<CalendarReminderFormScreen>(find.byType(CalendarReminderFormScreen));
    expect(form.readOnly, isTrue);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping bead item opens ItemFormScreen in read-only mode', (tester) async {
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
    expect(find.byType(ItemFormScreen), findsOneWidget);
    final form = tester.widget<ItemFormScreen>(find.byType(ItemFormScreen));
    expect(form.readOnly, isTrue);
    expect(harness.controller.tabIndex, equals(4));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping group item opens GroupFormScreen in read-only mode', (tester) async {
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
    expect(find.byType(GroupFormScreen), findsOneWidget);
    final form = tester.widget<GroupFormScreen>(find.byType(GroupFormScreen));
    expect(form.readOnly, isTrue);
    expect(harness.controller.tabIndex, equals(4));

    await tester.pumpWidget(const SizedBox());
  });
}
