import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:prayer_assistant/main.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';
import 'package:prayer_assistant/src/ui/app_shell.dart';

import '../helpers/test_harness.dart';

/// Golden test outline.
///
/// Baselines are intentionally NOT committed: run locally with
/// `flutter test --update-goldens test/golden` and review the generated
/// `test/golden/goldens/*.png` files before deciding to commit them.
///
/// Every case is `skip: true` by default so the suite stays green in CI.
/// Remove the skip when baselines are ready to be locked in.

Future<Widget> _buildApp() async {
  final harness = TestHarness.create();
  await harness.initialize();
  addTearDown(harness.controller.dispose);
  return PrayerAssistantApp(controller: harness.controller);
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testWidgets('app shell - light theme', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AppShell),
      matchesGoldenFile('goldens/app_shell_light.png'),
    );
  }, skip: true);

  testWidgets('app shell - dark theme', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();
    addTearDown(harness.controller.dispose);
    harness.controller.updateThemePreference(AppThemePreference.dark);
    await tester.pumpWidget(PrayerAssistantApp(controller: harness.controller));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AppShell),
      matchesGoldenFile('goldens/app_shell_dark.png'),
    );
  }, skip: true);

  testWidgets('home screen with a selected location', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AppShell),
      matchesGoldenFile('goldens/home_selected_location.png'),
    );
  }, skip: true);

  testWidgets('reminder settings screen', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/reminder_settings.png'),
    );
  }, skip: true);

  testWidgets('preferences screen', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/preferences.png'),
    );
  }, skip: true);

  testWidgets('history screen - prayer times tab', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.history_outlined));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/history_prayer_times.png'),
    );
  }, skip: true);

  testWidgets('calendar tab', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/calendar.png'),
    );
  }, skip: true);

  testWidgets('tesbih tab with seeded items', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.panorama_fish_eye_outlined));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/tesbih.png'),
    );
  }, skip: true);
}