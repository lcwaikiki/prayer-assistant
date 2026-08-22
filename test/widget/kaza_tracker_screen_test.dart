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

  testWidgets('renders KazaTrackerScreen and increments prayer count on + tap',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.saveKazaTracker(any()))
        .thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(tester, harness, const KazaTrackerScreen());

    expect(find.byIcon(Icons.done_all), findsOneWidget);


    expect(find.text('Total Remaining'), findsOneWidget);

    // Tap + on Fajr prayer row
    final addButtons = find.byIcon(Icons.add_circle_outline);
    expect(addButtons, findsWidgets);

    await tester.tap(addButtons.first);
    await tester.pumpAndSettle();

    expect(harness.controller.kazaTracker.fajrCompleted, 1);
    verify(() => harness.database.saveKazaTracker(any())).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('batch log +1 full day increments all 6 prayers', (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.saveKazaTracker(any()))
        .thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(tester, harness, const KazaTrackerScreen());

    final batchButton = find.text('+1 Full Day');
    expect(batchButton, findsOneWidget);

    await tester.tap(batchButton);
    await tester.pumpAndSettle();

    expect(harness.controller.kazaTracker.fajrCompleted, 1);
    expect(harness.controller.kazaTracker.dhuhrCompleted, 1);
    expect(harness.controller.kazaTracker.asrCompleted, 1);
    expect(harness.controller.kazaTracker.maghribCompleted, 1);
    expect(harness.controller.kazaTracker.ishaCompleted, 1);
    expect(harness.controller.kazaTracker.witrCompleted, 1);

    await tester.pumpWidget(const SizedBox());
  });
}
