import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/services/location_resolver.dart';
import 'package:prayer_assistant/src/ui/location_screen.dart';

import '../helpers/test_app.dart';
import '../helpers/test_harness.dart';

void main() {
  testWidgets('save is disabled until a district is picked', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: LocationScreen()),
    );

    final saveButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Save Location'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(saveButton.onPressed, isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('selecting country, state and district enables saving',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.api.getCountries()).thenAnswer(
      (_) async => [sampleLocationNode(id: 'tr', name: 'Türkiye')],
    );
    when(() => harness.api.getStates('tr')).thenAnswer(
      (_) async => [sampleLocationNode(id: '34', name: 'Istanbul')],
    );
    when(() => harness.api.getDistricts('34')).thenAnswer(
      (_) async => [sampleLocationNode(id: '541', name: 'Uskudar')],
    );
    when(
      () => harness.database.saveSelectedLocation(any()),
    ).thenAnswer((_) async {});
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
      const Scaffold(body: LocationScreen()),
    );

    await _pickDropdown(tester, 'Country', 'Türkiye');
    await _pickDropdown(tester, 'State / City', 'Istanbul');
    await _pickDropdown(tester, 'District', 'Uskudar');

    final saveButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Save Location'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(saveButton.onPressed, isNotNull);

    await tester.tap(find.text('Save Location'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(harness.controller.error, isNull);
    expect(harness.controller.selectedLocation!.districtId, '541');
    expect(harness.controller.tabIndex, 2);

    verify(() => harness.database.saveSelectedLocation(any())).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows the saved location confirmation card', (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.loadSelectedLocation()).thenAnswer(
      (_) async => sampleSelectedLocation(),
    );
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: LocationScreen()),
    );

    expect(find.text('Selected: Uskudar, Istanbul, Turkiye'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('retries the option fetch when startup left the list empty',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.api.getCountries()).thenThrow(Exception('network down'));
    await harness.initialize();
    expect(harness.controller.countries, isEmpty);
    expect(harness.controller.error, contains('network down'));

    when(() => harness.api.getCountries()).thenAnswer(
      (_) async => [sampleLocationNode(id: 'tr', name: 'Türkiye')],
    );

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: LocationScreen()),
    );

    expect(harness.controller.countries, hasLength(1));
    expect(harness.controller.error, isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows a stale startup error only once', (tester) async {
    final harness = TestHarness.create();
    when(() => harness.api.getCountries()).thenThrow(Exception('network down'));
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: LocationScreen()),
    );
    expect(find.byType(SnackBar), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);

    harness.controller.notifyListeners();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SnackBar), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('use current location fills the dropdowns without saving',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.locationResolver.resolveFromDevice()).thenAnswer(
      (_) async => DeviceLocationGuess(
        country: 'Turkey',
        state: 'Istanbul',
        city: 'Uskudar',
        district: 'Uskudar',
      ),
    );
    when(() => harness.api.getCountries()).thenAnswer(
      (_) async => [sampleLocationNode(id: 'tr', name: 'Türkiye')],
    );
    when(() => harness.api.getStates(any())).thenAnswer(
      (_) async => [sampleLocationNode(id: '34', name: 'Istanbul')],
    );
    when(() => harness.api.getDistricts(any())).thenAnswer(
      (_) async => [sampleLocationNode(id: '541', name: 'Uskudar')],
    );
    when(
      () => harness.locationResolver.bestMatch(any(), any()),
    ).thenAnswer((invocation) {
      final guesses = invocation.positionalArguments[1] as List<String>;
      if (guesses.first == 'Turkey') {
        return sampleLocationNode(id: 'tr', name: 'Türkiye');
      }
      if (guesses.first == 'Istanbul') {
        return sampleLocationNode(id: '34', name: 'Istanbul');
      }
      return sampleLocationNode(id: '541', name: 'Uskudar');
    });
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const Scaffold(body: LocationScreen()),
    );

    await tester.tap(find.text('Use Current Location'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(harness.controller.selectedLocation, isNull);
    verify(() => harness.locationResolver.resolveFromDevice()).called(1);
    verifyNever(() => harness.database.saveSelectedLocation(any()));
    expect(find.text('Türkiye'), findsOneWidget);
    expect(find.text('Istanbul'), findsOneWidget);
    expect(find.text('Uskudar'), findsOneWidget);

    final saveButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Save Location'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(saveButton.onPressed, isNotNull);

    await tester.pumpWidget(const SizedBox());
  });
}

Future<void> _pickDropdown(
  WidgetTester tester,
  String label,
  String option,
) async {
  await tester.tap(find.text(label));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text(option).last);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}