import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/models/fasting_models.dart';
import 'package:prayer_assistant/src/ui/track_screen.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import '../helpers/test_harness.dart';

void main() {
  testWidgets('TrackScreen renders Prayer Analytics, Qadaa, and Fasting sub-tabs',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.loadSelectedLocation())
        .thenAnswer((_) async => sampleSelectedLocation());
    when(() => harness.database.loadFastingLogs())
        .thenAnswer((_) async => <String, FastingLog>{});
    when(() => harness.api.getYearlyPrayerTimes(
          districtId: any(named: 'districtId'),
          year: any(named: 'year'),
        )).thenAnswer((_) async => [samplePrayerDay(date: DateTime.now())]);

    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: TrackScreen()),
    );

    // Verify all 3 sub-tabs render in order
    expect(find.text('Prayer Analytics'), findsOneWidget);
    expect(find.text('Prayer Qadaa'), findsOneWidget);
    expect(find.text('Fasting'), findsOneWidget);


    // Switch to Fasting tab
    await tester.tap(find.text('Fasting'));
    await tester.pumpAndSettle();

    expect(find.text('Total Fasts Logged'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
