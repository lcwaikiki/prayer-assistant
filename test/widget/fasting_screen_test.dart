import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/models/fasting_models.dart';
import 'package:prayer_assistant/src/ui/fasting_screen.dart';
import 'package:prayer_assistant/src/ui/widgets/iftar_suhoor_countdown_card.dart';

import '../helpers/test_app.dart';
import '../helpers/test_harness.dart';

void main() {
  testWidgets('IftarSuhoorCountdownCard renders live ticker title and progress bar',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.loadSelectedLocation())
        .thenAnswer((_) async => sampleSelectedLocation());
    when(() => harness.api.getYearlyPrayerTimes(
          districtId: any(named: 'districtId'),
          year: any(named: 'year'),
        )).thenAnswer((_) async => [samplePrayerDay(date: DateTime.now())]);

    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: IftarSuhoorCountdownCard()),
    );

    expect(find.byType(IftarSuhoorCountdownCard), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('IftarSuhoorCountdownCard renders localized progress and labels in Russian',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.loadSelectedLocation())
        .thenAnswer((_) async => sampleSelectedLocation());
    when(() => harness.api.getYearlyPrayerTimes(
          districtId: any(named: 'districtId'),
          year: any(named: 'year'),
        )).thenAnswer((_) async => [samplePrayerDay(date: DateTime.now())]);

    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: IftarSuhoorCountdownCard()),
      locale: const Locale('ru'),
    );

    // Tap to expand
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    // In Russian, Suhoor label contains "Сухур" and Iftar contains "Ифтар"
    expect(find.textContaining('Сухур'), findsWidgets);
    expect(find.textContaining('Ифтар'), findsWidgets);
    // Percentage elapsed text contains "прошло"
    expect(find.textContaining('прошло'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('FastingScreen renders countdown, statistics cards, and calendar logger',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.loadSelectedLocation())
        .thenAnswer((_) async => sampleSelectedLocation());
    when(() => harness.api.getYearlyPrayerTimes(
          districtId: any(named: 'districtId'),
          year: any(named: 'year'),
        )).thenAnswer((_) async => [samplePrayerDay(date: DateTime.now())]);

    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const FastingScreen(),
    );

    // Verify Fasting title renders
    expect(find.text('Fasting'), findsOneWidget);


    // Verify statistics cards render
    expect(find.text('Total Fasts Logged'), findsOneWidget);
    expect(find.text('Ramadan Fast'), findsOneWidget);
    expect(find.text('Sunnah Fast'), findsOneWidget);
    expect(find.text('Make-up (Qadaa) Fast'), findsOneWidget);

    // Verify calendar logger title renders
    expect(find.text('Fasting Calendar Logger'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('FastingScreen day cell does not overflow with detailed information on mobile width',
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
    when(() => harness.database.loadSelectedLocation())
        .thenAnswer((_) async => sampleSelectedLocation());
    when(() => harness.api.getYearlyPrayerTimes(
          districtId: any(named: 'districtId'),
          year: any(named: 'year'),
        )).thenAnswer((_) async => [samplePrayerDay(date: DateTime.now())]);
    when(() => harness.database.loadFastingLogs()).thenAnswer(
      (_) async => {
        todayKey: FastingLog(dateKey: todayKey, type: FastingType.ramadan),
      },
    );
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const FastingScreen(),
    );

    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

