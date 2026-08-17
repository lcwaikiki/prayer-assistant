import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/ui/history_screen.dart';

import '../helpers/test_app.dart';
import '../helpers/test_harness.dart';

void main() {
  testWidgets('prompts for a location when none is selected', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: HistoryScreen()),
    );

    expect(
      find.text('Select a location first to view 1-year prayer list.'),
      findsOneWidget,
    );
    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('renders the prayer times table for the cached year',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.loadSelectedLocation()).thenAnswer(
      (_) async => sampleSelectedLocation(),
    );
    when(
      () => harness.database.getDay(
        districtId: any(named: 'districtId'),
        date: any(named: 'date'),
      ),
    ).thenAnswer((_) async => samplePrayerDay());
    when(
      () => harness.database.getRange(
        districtId: any(named: 'districtId'),
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer((_) async => [samplePrayerDay()]);
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: HistoryScreen()),
    );

    expect(find.text('Prayer Times'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Fajr'), findsWidgets);
    expect(find.text('05:10'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('calendar tab shows the hijri calendar view', (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.loadSelectedLocation()).thenAnswer(
      (_) async => sampleSelectedLocation(),
    );
    when(
      () => harness.database.getDay(
        districtId: any(named: 'districtId'),
        date: any(named: 'date'),
      ),
    ).thenAnswer((_) async => samplePrayerDay());
    when(
      () => harness.database.getRange(
        districtId: any(named: 'districtId'),
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer((_) async => [samplePrayerDay()]);
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: HistoryScreen()),
    );

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    expect(find.bySubtype<SegmentedButton>(), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}