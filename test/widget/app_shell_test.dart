import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/ui/app_shell.dart';
import 'package:prayer_assistant/src/ui/qibla_screen.dart';

import '../helpers/test_app.dart';
import '../helpers/test_harness.dart';

void main() {
  Widget qiblaTab() => QiblaScreen(
        compassStreamProvider: () => null,
        loadPosition: () async => (lat: 41.0082, lon: 28.9784),
      );

  testWidgets('shows a loading spinner while initializing', (tester) async {
    final harness = TestHarness.create();

    await pumpWithHarness(tester, harness, const AppShell(), settle: false);
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows all five tabs after initialization', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, AppShell(qiblaScreen: qiblaTab()));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Qibla'), findsOneWidget);
    expect(find.text('Track'), findsOneWidget);


    expect(find.text('Location'), findsNothing);
    expect(find.text('Dates'), findsOneWidget);
    expect(find.text('Beads'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping a tab switches the controller tab index',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, AppShell(qiblaScreen: qiblaTab()));

    await tester.tap(find.text('Beads'));
    await tester.pump();

    expect(harness.controller.tabIndex, 4);

    await tester.pumpWidget(const SizedBox());
  });


  testWidgets('reminders toggle switches its tooltip and silences reminders',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, AppShell(qiblaScreen: qiblaTab()));

    expect(find.byTooltip('Turn reminders off'), findsOneWidget);

    await tester.tap(find.byTooltip('Turn reminders off'));
    await tester.pump();

    expect(harness.controller.remindersSilenced, isTrue);
    expect(find.byTooltip('Turn reminders on'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('theme toggle flips the theme preference', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, AppShell(qiblaScreen: qiblaTab()));

    await tester.tap(find.byTooltip('Toggle light/dark'));
    await tester.pump();

    expect(harness.controller.themeMode, isNot(ThemeMode.system));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('preferences button opens the preferences screen',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, AppShell(qiblaScreen: qiblaTab()));

    await tester.tap(find.byTooltip('Preferences'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Preferences'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('saving a location from preferences returns to the home tab',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.api.getCountries()).thenAnswer(
      (_) async => [sampleLocationNode(id: 'tr', name: 'Türkiye')],
    );
    when(() => harness.api.getStates(any())).thenAnswer(
      (_) async => [sampleLocationNode(id: '34', name: 'Istanbul')],
    );
    when(() => harness.api.getDistricts(any())).thenAnswer(
      (_) async => [sampleLocationNode(id: '541', name: 'Uskudar')],
    );
    when(() => harness.database.saveSelectedLocation(any()))
        .thenAnswer((_) async {});
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

    await pumpWithHarness(tester, harness, AppShell(qiblaScreen: qiblaTab()));

    await tester.tap(find.byTooltip('Preferences'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Location'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    await _pickDropdown(tester, 'Country', 'Türkiye');
    await _pickDropdown(tester, 'State / City', 'Istanbul');
    await _pickDropdown(tester, 'District', 'Uskudar');

    await tester.tap(find.text('Save Location'));
    await tester.pumpAndSettle();

    expect(harness.controller.tabIndex, 2);

    expect(harness.controller.selectedLocation!.districtId, '541');
    expect(find.text('Save Location'), findsNothing);
    expect(find.text('Today'), findsWidgets);
    verify(() => harness.database.saveSelectedLocation(any())).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('dates sub-tab selection survives tab switches',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, AppShell(qiblaScreen: qiblaTab()));

    await tester.tap(find.text('Dates'));
    await tester.pumpAndSettle();

    expect(find.text('Prayer Times'), findsOneWidget);
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hide secondary date'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dates'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Hide secondary date'), findsOneWidget);

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
