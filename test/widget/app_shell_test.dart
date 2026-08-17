import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/ui/app_shell.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('shows a loading spinner while initializing', (tester) async {
    final harness = TestHarness.create();

    await pumpWithHarness(tester, harness, const AppShell(), settle: false);
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows all four tabs after initialization', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const AppShell());

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Dates'), findsOneWidget);
    expect(find.text('Beads'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping a tab switches the controller tab index',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const AppShell());

    await tester.tap(find.text('Beads'));
    await tester.pump();

    expect(harness.controller.tabIndex, 3);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reminders toggle switches its tooltip and silences reminders',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const AppShell());

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

    await pumpWithHarness(tester, harness, const AppShell());

    await tester.tap(find.byTooltip('Toggle light/dark'));
    await tester.pump();

    expect(harness.controller.themeMode, isNot(ThemeMode.system));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('preferences button opens the preferences screen',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const AppShell());

    await tester.tap(find.byTooltip('Preferences'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Preferences'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}