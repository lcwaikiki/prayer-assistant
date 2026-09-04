import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/ui/analytics_dashboard_screen.dart';


import '../helpers/test_harness.dart';

void main() {
  testWidgets('AnalyticsDashboardScreen renders streaks, heatmap, and prayer breakdown',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.loadPrayerCompletions()).thenAnswer(
      (_) async => {
        '2026-08-22': ['imsak', 'ogle', 'ikindi', 'aksam', 'yatsi'],
        '2026-08-23': ['imsak', 'ogle', 'ikindi', 'aksam', 'yatsi'],
      },
    );
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: AnalyticsDashboardScreen()),
    );

    // Verify streak cards render
    expect(find.text('Current Streak'), findsOneWidget);
    expect(find.text('Longest Streak'), findsOneWidget);

    // Verify monthly heatmap section renders
    expect(find.text('Monthly Completion'), findsOneWidget);

    // Verify breakdown section renders
    expect(find.text('Prayer Breakdown'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);
    expect(find.text('Asr'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('AnalyticsDashboardScreen month navigation updates displayed month',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: AnalyticsDashboardScreen()),
    );

    expect(find.byTooltip('Previous month'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Next month'), findsOneWidget);
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('AnalyticsDashboardScreen day cell does not overflow with detailed information on mobile width',
      (tester) async {
    tester.view.physicalSize = const Size(360 * 2.0, 740 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final harness = TestHarness.create();
    when(() => harness.database.loadPrayerCompletions()).thenAnswer(
      (_) async => {
        todayKey: ['imsak', 'ogle', 'ikindi', 'aksam', 'yatsi'],
      },
    );
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: AnalyticsDashboardScreen()),
    );

    // Verify cell content renders
    expect(find.text('5/5'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}

