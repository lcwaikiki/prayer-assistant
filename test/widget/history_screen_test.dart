import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';
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

  testWidgets('prayer times table keeps its scroll position across sub-tabs',
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
    ).thenAnswer(
      (_) async => List.generate(
        365,
        (i) => PrayerDay(
          date: DateTime(2026, 1, 1).add(Duration(days: i)),
          imsak: '05:00',
          gunes: '06:30',
          ogle: '13:00',
          ikindi: '16:45',
          aksam: '19:30',
          yatsi: '21:00',
          hijriDate: '1 Safar 1448',
        ),
      ),
    );
    await harness.initialize();
    harness.controller.setTab(3);


    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: HistoryScreen()),
    );

    expect(find.text('01/01'), findsOneWidget);
    for (var i = 0; i < 10 && !tester.any(find.text('December 2026')); i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();
    }
    expect(find.text('December 2026'), findsOneWidget);
    expect(find.text('01/01'), findsNothing);

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prayer Times'));
    await tester.pumpAndSettle();

    expect(find.text('December 2026'), findsOneWidget);
    expect(find.text('01/01'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });
}