import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/kaza/models/kaza_tracker.dart';
import 'package:prayer_assistant/src/kaza/screens/kaza_tracker_screen.dart';

import '../helpers/test_harness.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const KazaTracker());
  });

  testWidgets('tapping a prayer tile logs one for today',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.saveKazaTracker(any()))
        .thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(tester, harness, const KazaTrackerScreen());

    expect(find.text('Total Remaining'), findsOneWidget);
    expect(find.text('Tap a prayer to log it'), findsOneWidget);

    await tester.tap(find.text('Fajr').first);
    await tester.pumpAndSettle();

    expect(harness.controller.kazaTracker.completedFor('fajr'), 1);
    verify(() => harness.database.saveKazaTracker(any())).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('all prayers plus logs one of each for today', (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.saveKazaTracker(any()))
        .thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(tester, harness, const KazaTrackerScreen());

    final addAll = find.widgetWithIcon(IconButton, Icons.add);
    expect(addAll, findsOneWidget);

    await tester.tap(addAll);
    await tester.pumpAndSettle();

    expect(harness.controller.kazaTracker.completedFor('fajr'), 1);
    expect(harness.controller.kazaTracker.completedFor('dhuhr'), 1);
    expect(harness.controller.kazaTracker.completedFor('asr'), 1);
    expect(harness.controller.kazaTracker.completedFor('maghrib'), 1);
    expect(harness.controller.kazaTracker.completedFor('isha'), 1);
    expect(harness.controller.kazaTracker.completedFor('witr'), 1);

    await tester.pumpWidget(const SizedBox());
  });
}
