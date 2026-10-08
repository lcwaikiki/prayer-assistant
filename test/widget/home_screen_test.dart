import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/ui/home_screen.dart';

import '../helpers/test_app.dart';
import '../helpers/test_harness.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('prayer_assistant/native_reminders'),
      (call) async {
        if (call.method == 'hasDndPermission') {
          return true;
        }
        return null;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_timezone'),
      (call) async => 'UTC',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('wakelock_plus'),
      (call) async => true,
    );
  });
  testWidgets('shows the empty state when no location is selected', (
    tester,
  ) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const HomeScreen(), settle: false);
    await tester.pump();

    expect(find.text('No location selected'), findsOneWidget);
    expect(find.text('Refresh'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('refresh icon opens the location screen without a location', (
    tester,
  ) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const HomeScreen(), settle: false);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(find.text('Select Your Location'), findsOneWidget);
    expect(find.text('Use Current Location'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('offers a refresh action when prayer data is missing', (
    tester,
  ) async {
    final harness = TestHarness.create();
    when(
      () => harness.database.loadSelectedLocation(),
    ).thenAnswer((_) async => sampleSelectedLocation());
    await harness.initialize();

    await pumpWithHarness(tester, harness, const HomeScreen(), settle: false);
    await tester.pump();

    expect(find.text('No prayer times in cache'), findsOneWidget);

    await tester.tap(find.text('Refresh'));
    await tester.pump();

    verify(
      () => harness.database.getDay(
        districtId: any(named: 'districtId'),
        date: any(named: 'date'),
      ),
    ).called(greaterThanOrEqualTo(2));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('renders all six prayer rows with a saved location and data', (
    tester,
  ) async {
    final harness = TestHarness.create();
    when(
      () => harness.database.loadSelectedLocation(),
    ).thenAnswer((_) async => sampleSelectedLocation());
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

    await pumpWithHarness(tester, harness, const HomeScreen(), settle: false);
    await tester.pump();

    for (final prayer in [
      'Fajr',
      'Sunrise',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha',
    ]) {
      expect(find.widgetWithText(ListTile, prayer), findsOneWidget);
    }
    expect(find.text('05:10'), findsWidgets);
    expect(find.textContaining('Uskudar'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping a prayer row opens its reminder settings', (
    tester,
  ) async {
    final harness = TestHarness.create();
    when(
      () => harness.database.loadSelectedLocation(),
    ).thenAnswer((_) async => sampleSelectedLocation());
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

    await pumpWithHarness(tester, harness, const HomeScreen(), settle: false);
    await tester.pump();

    await tester.tap(find.widgetWithText(ListTile, 'Fajr'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Fajr Reminder'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'On time'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows the refresh icon button disabled while busy', (
    tester,
  ) async {
    final harness = TestHarness.create();
    when(
      () => harness.database.loadSelectedLocation(),
    ).thenAnswer((_) async => sampleSelectedLocation());
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

    await pumpWithHarness(tester, harness, const HomeScreen(), settle: false);
    await tester.pump();

    final refreshIcon = find.widgetWithIcon(IconButton, Icons.refresh);
    expect(refreshIcon, findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping the reminder icon toggles the on-time reminder', (
    tester,
  ) async {
    final harness = TestHarness.create();
    when(
      () => harness.database.loadSelectedLocation(),
    ).thenAnswer((_) async => sampleSelectedLocation());
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

    await pumpWithHarness(tester, harness, const HomeScreen(), settle: false);
    await tester.pump();

    final fajrTile = find.widgetWithText(ListTile, 'Fajr');
    final offIcon = find.descendant(
      of: fajrTile,
      matching: find.byIcon(Icons.notifications_off_outlined),
    );
    expect(offIcon, findsOneWidget);

    await tester.tap(offIcon);
    await tester.pump();

    expect(
      find.descendant(
        of: fajrTile,
        matching: find.byIcon(Icons.notifications_active),
      ),
      findsOneWidget,
    );
    verify(() => harness.database.saveReminderSettings(any())).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('share button forwards today\'s times through onShare', (
    tester,
  ) async {
    final harness = TestHarness.create();
    when(
      () => harness.database.loadSelectedLocation(),
    ).thenAnswer((_) async => sampleSelectedLocation());
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

    String? sharedText;
    await pumpWithHarness(
      tester,
      harness,
      HomeScreen(onShare: (text) => sharedText = text),
      settle: false,
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.share_outlined));
    await tester.pump();

    expect(sharedText, isNotNull);
    expect(sharedText, contains('Uskudar, Istanbul, Turkiye'));
    expect(sharedText, contains('Fajr: 05:10'));
    expect(sharedText, contains('Dhuhr: 12:35'));
    expect(sharedText, contains('Isha: 19:45'));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('renders cards in custom order based on todayCardsOrder', (
    tester,
  ) async {
    final harness = TestHarness.create();
    when(
      () => harness.database.loadSelectedLocation(),
    ).thenAnswer((_) async => sampleSelectedLocation());
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
    when(
      () => harness.database.loadTodayCardsOrder(),
    ).thenAnswer(
      (_) async => [
        'prayer_times',
        'moon_phase',
        'next_prayer',
        'daily_wisdom',
        'iftar_suhoor',
        'upcoming_reminders',
      ],
    );
    await harness.initialize();

    await pumpWithHarness(tester, harness, const HomeScreen(), settle: false);
    await tester.pump();

    expect(find.byType(ReorderableListView), findsOneWidget);
    expect(find.byKey(const ValueKey('today_card_prayer_times')), findsOneWidget);
    expect(find.byKey(const ValueKey('today_card_moon_phase')), findsOneWidget);

    final prayerCardPos = tester.getTopLeft(find.byKey(const ValueKey('today_card_prayer_times')));
    final moonCardPos = tester.getTopLeft(find.byKey(const ValueKey('today_card_moon_phase')));
    expect(prayerCardPos.dy, lessThan(moonCardPos.dy));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('long press and drag reorders cards on Today tab', (
    tester,
  ) async {
    final harness = TestHarness.create();
    when(
      () => harness.database.loadSelectedLocation(),
    ).thenAnswer((_) async => sampleSelectedLocation());
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

    await pumpWithHarness(tester, harness, const HomeScreen(), settle: false);
    await tester.pump();

    final moonPhaseCard = find.byKey(const ValueKey('today_card_moon_phase'));
    expect(moonPhaseCard, findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(moonPhaseCard));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(const Offset(0, -300));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    verify(() => harness.database.saveTodayCardsOrder(any())).called(greaterThanOrEqualTo(1));

    await tester.pumpWidget(const SizedBox());
  });
}
