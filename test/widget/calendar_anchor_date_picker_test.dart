import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/screens/calendar_anchor_date_picker.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets(
      'showAnchorDatePicker renders day cells without overflow on mobile width and text scaling',
      (tester) async {
    tester.view.physicalSize = const Size(360 * 2.0, 740 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 740),
          textScaler: TextScaler.linear(1.3),
        ),
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAnchorDatePicker(
              context,
              initialDate: DateTime(2026, 8, 17),
            ),
            child: const Text('Open Picker'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Picker'));
    await tester.pumpAndSettle();

    expect(find.text('17'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}
