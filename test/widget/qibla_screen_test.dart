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

  test('distanceToMeccaKm calculates distance to Mecca accurately', () {
    expect(distanceToMeccaKm(meccaLatitude, meccaLongitude), 0.0);
    final distIstanbul = distanceToMeccaKm(41.0082, 28.9784);
    expect(distIstanbul, closeTo(2430, 50));
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

  testWidgets('centers the dial horizontally on wide (tablet) screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

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

    final dial = find.byType(CustomPaint).first;
    final dialRect = tester.getRect(dial);
    expect(dialRect.center.dx, closeTo(512, 1));

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
    expect(find.text('Grant Location Permission'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('requesting permission button retries loading position', (
    tester,
  ) async {
    var callCount = 0;
    await tester.pumpWidget(
      testLocalizedApp(
        child: QiblaScreen(
          loadPosition: () async {
            callCount++;
            if (callCount == 1) {
              throw Exception('permission denied');
            }
            return (lat: 41.0082, lon: 28.9784);
          },
          compassStreamProvider: () => null,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('Grant Location Permission'), findsOneWidget);
    expect(callCount, 1);

    await tester.tap(find.text('Grant Location Permission'));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(callCount, 2);
    expect(find.text('Qibla: 152°'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
