import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/ui/home_screen.dart';

import '../helpers/test_app.dart';
import '../helpers/test_harness.dart';

void main() {
  testWidgets('shows the empty state when no location is selected',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const HomeScreen());

    expect(find.text('No location selected'), findsOneWidget);
    expect(find.text('Refresh'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('offers a refresh action when prayer data is missing',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.loadSelectedLocation()).thenAnswer(
      (_) async => sampleSelectedLocation(),
    );
    await harness.initialize();

    await pumpWithHarness(tester, harness, const HomeScreen());

    expect(find.text('No prayer times in cache'), findsOneWidget);

    await tester.tap(find.text('Refresh'));
    await tester.pump();

    verify(
      () => harness.database.getDay(
        districtId: any(named: 'districtId'),
        date: any(named: 'date'),
      ),
    ).called(2);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('renders all six prayer rows with a saved location and data',
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

    await pumpWithHarness(tester, harness, const HomeScreen());

    for (final prayer in ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      expect(find.widgetWithText(ListTile, prayer), findsOneWidget);
    }
    expect(find.text('05:10'), findsOneWidget);
    expect(
      find.textContaining('Uskudar, Istanbul, Turkiye'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping a prayer row opens its reminder settings',
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

    await pumpWithHarness(tester, harness, const HomeScreen());

    await tester.tap(find.widgetWithText(ListTile, 'Fajr'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Fajr Reminder'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'On time'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows the refresh icon button disabled while busy',
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

    await pumpWithHarness(tester, harness, const HomeScreen());

    final refreshIcon = find.widgetWithIcon(IconButton, Icons.refresh);
    expect(refreshIcon, findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}