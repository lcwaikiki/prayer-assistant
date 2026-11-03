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
      settle: false,
    );
    await tester.pump(const Duration(milliseconds: 200));

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
      settle: false,
    );
    await tester.pump(const Duration(milliseconds: 200));

    // Tap to expand
    await tester.tap(find.byType(InkWell).first);
    await tester.pump(const Duration(milliseconds: 300));

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
      settle: false,
    );
    await tester.pump(const Duration(milliseconds: 200));

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
      settle: false,
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('IftarSuhoorCountdownCard rounds remaining minutes up when seconds are omitted',
      (tester) async {
    final now = DateTime.now();
    // Test Suhoor countdown when after Aksam
    final imsakToday = DateTime(now.year, now.month, now.day, 5, 0);

    final harness = TestHarness.create();
    when(() => harness.database.loadSelectedLocation())
        .thenAnswer((_) async => sampleSelectedLocation());
    final testDay = samplePrayerDay(
      date: now,
      imsak: '05:00',
      aksam: '06:00',
    );
    when(() => harness.api.getYearlyPrayerTimes(
          districtId: any(named: 'districtId'),
          year: any(named: 'year'),
        )).thenAnswer((_) async => [testDay]);
    when(() => harness.database.getRange(
          districtId: any(named: 'districtId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => [testDay]);

    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: IftarSuhoorCountdownCard()),
      settle: false,
    );
    await tester.pump(const Duration(milliseconds: 200));

    // Target is tomorrow's imsak at 05:00
    final targetTime = imsakToday.add(const Duration(days: 1));
    final remainingSeconds = targetTime.difference(DateTime.now()).inSeconds;
    final totalMinutes = (remainingSeconds + 59) ~/ 60;
    final expectedTime = '${(totalMinutes ~/ 60).toString().padLeft(2, '0')}:${(totalMinutes % 60).toString().padLeft(2, '0')}';

    expect(find.text(expectedTime), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('IftarSuhoorCountdownCard targets tomorrow distinct imsak time after aksam',
      (tester) async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowImsak = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 5, 1);

    final harness = TestHarness.create();
    when(() => harness.database.loadSelectedLocation())
        .thenAnswer((_) async => sampleSelectedLocation());
    final testDays = [
      samplePrayerDay(
        date: now,
        imsak: '05:00',
        aksam: '06:00',
      ),
      samplePrayerDay(
        date: tomorrow,
        imsak: '05:01',
        aksam: '06:01',
      ),
    ];
    when(() => harness.api.getYearlyPrayerTimes(
          districtId: any(named: 'districtId'),
          year: any(named: 'year'),
        )).thenAnswer((_) async => testDays);
    when(() => harness.database.getRange(
          districtId: any(named: 'districtId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => testDays);

    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: IftarSuhoorCountdownCard()),
      settle: false,
    );
    await tester.pump(const Duration(milliseconds: 200));

    // Target is tomorrow's distinct imsak at 05:01
    final remainingSeconds = tomorrowImsak.difference(DateTime.now()).inSeconds;
    final totalMinutes = (remainingSeconds + 59) ~/ 60;
    final expectedTime = '${(totalMinutes ~/ 60).toString().padLeft(2, '0')}:${(totalMinutes % 60).toString().padLeft(2, '0')}';

    expect(find.text(expectedTime), findsOneWidget);

    // Expand to verify label shows tomorrow's imsak 05:01
    await tester.tap(find.byType(InkWell).first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('05:01'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('IftarSuhoorCountdownCard switches between iftar and suhoor modes',
      (tester) async {
    final now = DateTime.now();
    final harness = TestHarness.create();
    when(() => harness.database.loadSelectedLocation())
        .thenAnswer((_) async => sampleSelectedLocation());

    // Scenario: currently fasting (imsak in past, aksam in future)
    final fastingDay = samplePrayerDay(
      date: now,
      imsak: '00:01',
      aksam: '23:59',
    );
    when(() => harness.api.getYearlyPrayerTimes(
          districtId: any(named: 'districtId'),
          year: any(named: 'year'),
        )).thenAnswer((_) async => [fastingDay]);
    when(() => harness.database.getRange(
          districtId: any(named: 'districtId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => [fastingDay]);

    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: IftarSuhoorCountdownCard()),
      settle: false,
    );
    await tester.pump(const Duration(milliseconds: 200));

    // Shows Iftar Countdown title
    expect(find.text('Time to Iftar'), findsOneWidget);

    // Expand and verify Iftar badge
    await tester.tap(find.byType(InkWell).first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('23:59'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });
}
