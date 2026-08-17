import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:prayer_assistant/main.dart' as app;

/// Integration smoke-test outline.
///
/// These boot the real application (real database, Hive, notification
/// channels, network) and must run on a device/emulator:
///
///   `flutter test integration_test -d <device>`
///
/// They do NOT run under plain `flutter test`.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots to the home screen', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('location flow: select a district and see prayer times',
      (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    // Outline: open the location picker, pick a country -> state ->
    // district, and verify the home screen renders times for the new
    // selection.
  });

  testWidgets('tesbih flow: create an item and tap through a full round',
      (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    // Outline: switch to the tesbih tab, add a beads item, open it, tap
    // through `check` taps and verify progress resets at the count
    // boundary.
  });

  testWidgets('calendar flow: add a reminder from a tapped day',
      (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    // Outline: open the calendar tab, tap a day, add a reminder, and
    // verify it appears in the day-detail sheet.
  });
}