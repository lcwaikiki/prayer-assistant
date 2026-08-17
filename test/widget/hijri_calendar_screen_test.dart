import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/hijri_utils.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/calendar/screens/hijri_calendar_screen.dart';

import '../helpers/test_harness.dart';

void main() {
  Future<void> switchToGregorian(WidgetTester tester) async {
    await tester.tap(find.text('Gregorian'));
    await tester.pumpAndSettle();
  }

  Future<void> hideSecondary(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Hide secondary date'));
    await tester.pumpAndSettle();
  }

  Future<void> openDayDetail(WidgetTester tester) async {
    await tester.drag(find.byType(GridView), const Offset(0, -150));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, '17'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the hijri month title and weekday headers',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      HijriCalendarScreen(initialDate: DateTime(2026, 8, 17)),
    );

    final hijriMonth = HijriMonth.fromDate(DateTime(2026, 8, 17));
    expect(
      find.text('${hijriMonth.longMonthName} ${hijriMonth.year}'),
      findsOneWidget,
    );
    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Sat'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('switching to the gregorian basis shows the gregorian month',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      HijriCalendarScreen(initialDate: DateTime(2026, 8, 17)),
    );

    await switchToGregorian(tester);
    await hideSecondary(tester);

    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('17'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('month navigation shifts the focused month', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      HijriCalendarScreen(initialDate: DateTime(2026, 8, 17)),
    );

    await switchToGregorian(tester);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('August 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Today'));
    await tester.pumpAndSettle();
    expect(find.text('August 2026'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping a day opens the detail sheet', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      HijriCalendarScreen(initialDate: DateTime(2026, 8, 17)),
    );

    await switchToGregorian(tester);
    await hideSecondary(tester);
    await openDayDetail(tester);

    expect(find.text('August 17, 2026'), findsOneWidget);
    expect(find.text('No reminders on this day'), findsOneWidget);
    expect(find.text('Add reminder'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the sheet lists reminders occurring on the tapped day',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();
    harness.controller.addCalendarReminder(
      CalendarReminder(
        id: 'r1',
        title: 'Test Reminder',
        anchorAt: DateTime(2026, 8, 17, 9, 0),
        recurrence: ReminderRecurrence.once,
      ),
    );

    await pumpWithHarness(
      tester,
      harness,
      HijriCalendarScreen(initialDate: DateTime(2026, 8, 17)),
    );

    await switchToGregorian(tester);
    await hideSecondary(tester);
    await openDayDetail(tester);

    expect(find.text('Test Reminder'), findsOneWidget);
    expect(find.text('Once'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('deleting a reminder from the sheet offers undo',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();
    harness.controller.addCalendarReminder(
      CalendarReminder(
        id: 'r1',
        title: 'Test Reminder',
        anchorAt: DateTime(2026, 8, 17, 9, 0),
        recurrence: ReminderRecurrence.once,
      ),
    );

    await pumpWithHarness(
      tester,
      harness,
      HijriCalendarScreen(initialDate: DateTime(2026, 8, 17)),
    );

    await switchToGregorian(tester);
    await hideSecondary(tester);
    await openDayDetail(tester);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(harness.controller.calendarReminders, isEmpty);
    expect(find.text('"Test Reminder" deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(harness.controller.calendarReminders, hasLength(1));
    expect(
      harness.controller.calendarReminders.first.title,
      'Test Reminder',
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('adding a reminder from the sheet saves it via the form',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      HijriCalendarScreen(initialDate: DateTime(2026, 8, 17)),
    );

    await switchToGregorian(tester);
    await hideSecondary(tester);
    await openDayDetail(tester);

    await tester.tap(find.text('Add reminder'));
    await tester.pumpAndSettle();

    expect(find.text('New reminder'), findsOneWidget);
    expect(find.text('Aug 17, 2026'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'New Reminder');
    for (var i = 0; i < 6 && tester.any(find.text('Save')) == false; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(harness.controller.calendarReminders, hasLength(1));
    expect(
      harness.controller.calendarReminders.first.title,
      'New Reminder',
    );
    expect(find.text('August 2026'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}