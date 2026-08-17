import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/ui/qibla_screen.dart';
import 'package:prayer_assistant/src/utils/qibla_utils.dart';

import '../helpers/test_app.dart';

void main() {
  test('qiblaBearing returns the expected bearing for Istanbul', () {
    final bearing = qiblaBearing(41.0082, 28.9784);
    expect(bearing, closeTo(151.5, 1.0));
  });

  test('qiblaBearing is 0 at Mecca itself', () {
    expect(qiblaBearing(meccaLatitude, meccaLongitude), 0);
  });

  testWidgets('renders the bearing and position with injected streams', (
    tester,
  ) async {
    final headings = StreamController<double>();
    addTearDown(headings.close);

    await tester.pumpWidget(
      testLocalizedApp(
        child: QiblaScreen(
          headingStream: headings.stream,
          loadPosition: () async => (lat: 41.0082, lon: 28.9784),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Qibla: 152°'), findsOneWidget);
    expect(find.textContaining('41.01'), findsOneWidget);
    expect(
      find.text('Rotate your device until the needle points up.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('falls back to a fixed bearing when no compass is available', (
    tester,
  ) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: QiblaScreen(
          loadPosition: () async => (lat: 41.0082, lon: 28.9784),
          compassStreamProvider: () => null,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Qibla: 152°'), findsOneWidget);
    expect(
      find.text('Compass unavailable - showing fixed bearing.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows an error state when position cannot be loaded', (
    tester,
  ) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: QiblaScreen(
          loadPosition: () async => throw Exception('no gps'),
          compassStreamProvider: () => null,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Could not determine your location. Enable GPS and try again.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });
}
