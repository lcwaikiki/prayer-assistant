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
      locale: const Locale('en'),
      settle: false,
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

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
      locale: const Locale('en'),
      settle: false,
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.schedule), findsWidgets);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Moon Phase'), findsOneWidget);

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
      locale: const Locale('en'),
      settle: false,
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Calendar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

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
    ).thenAnswer((_) async => [samplePrayerDay()]);
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: HistoryScreen()),
      locale: const Locale('en'),
      settle: false,
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.schedule), findsWidgets);

    await tester.tap(find.text('Calendar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Calendar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.schedule), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('moon phase tab shows the moon calendar view', (tester) async {
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
      locale: const Locale('en'),
      settle: false,
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Moon Phase'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('White Days'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });
}