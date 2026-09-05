import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/screens/moon_calendar_screen.dart';

import '../helpers/test_app.dart';
import '../helpers/test_harness.dart';

void main() {
  testWidgets('MoonCalendarScreen renders month title, overview card, and day cells',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      MoonCalendarScreen(initialDate: DateTime(2026, 9, 5)),
    );

    expect(find.byType(MoonCalendarScreen), findsOneWidget);
    expect(find.textContaining('White Days'), findsWidgets);
    expect(find.byType(GridView), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('MoonCalendarScreen previous/next month controls shift focused month',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      MoonCalendarScreen(initialDate: DateTime(2026, 9, 5)),
    );

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
