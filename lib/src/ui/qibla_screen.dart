import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../l10n/l10n.dart';
import '../utils/qibla_utils.dart';

typedef QiblaPositionLoader = Future<({double lat, double lon})> Function();

Future<({double lat, double lon})> loadDevicePosition() async {
  final position = await Geolocator.getCurrentPosition();
  return (lat: position.latitude, lon: position.longitude);
}

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({
    super.key,
    this.headingStream,
    this.loadPosition,
    this.compassStreamProvider,
    this.embedded = true,
  });

  /// Injectable compass heading stream (degrees, 0-360). Defaults to the
  /// device magnetometer via [FlutterCompass.events].
  final Stream<double>? headingStream;

  /// Injectable position loader so tests can avoid the geolocator platform
  /// channel. Defaults to [loadDevicePosition].
  final QiblaPositionLoader? loadPosition;

  /// Injectable default-stream builder, mirroring [headingStream] for the
  /// fallback UI (fixed bearing, no needle rotation). Tests provide a null
  /// return so the magnetometer platform channel is never touched.
  final Stream<double>? Function()? compassStreamProvider;

  /// When true, renders only the body content without a Scaffold/AppBar so
  /// the screen can sit inside an outer shell (e.g. as a tab).
  final bool embedded;

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

Stream<double>? _defaultCompassStream() {
  try {
    return FlutterCompass.events?.map((e) => e.heading!);
  } catch (_) {
    return null;
  }
}

class _QiblaScreenState extends State<QiblaScreen> {
  Stream<double>? _effectiveHeadingStream;
  late final Future<({double lat, double lon})> _positionFuture;

  @override
  void initState() {
    super.initState();
    _effectiveHeadingStream =
        widget.headingStream ??
        (widget.compassStreamProvider ?? _defaultCompassStream)();
    _positionFuture = widget.loadPosition?.call() ?? loadDevicePosition();
  }

  @override
  Widget build(BuildContext context) {
    final body = FutureBuilder<({double lat, double lon})>(
      future: _positionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final position = snapshot.data;
        if (position == null) {
          return _ErrorState(
            message: context.l10n.qiblaLocationUnavailable,
            icon: Icons.location_off_outlined,
          );
        }
        final bearing = qiblaBearing(position.lat, position.lon);
        return _QiblaView(
          bearing: bearing,
          headingStream: _effectiveHeadingStream,
          locationLabel:
              '${position.lat.toStringAsFixed(2)}, ${position.lon.toStringAsFixed(2)}',
        );
      },
    );
    if (widget.embedded) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.qiblaTitle)),
      body: body,
    );
  }
}

class _QiblaView extends StatelessWidget {
  const _QiblaView({
    required this.bearing,
    required this.headingStream,
    required this.locationLabel,
  });

  final double bearing;
  final Stream<double>? headingStream;
  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Text(
              l10n.qiblaBearing(bearing.round()),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(locationLabel, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            if (headingStream == null)
              Expanded(
                child: _CompassDial(bearing: bearing, heading: 0, live: false),
              )
            else
              Expanded(
                child: StreamBuilder<double>(
                  stream: headingStream,
                  initialData: 0,
                  builder: (context, snapshot) {
                    final heading = snapshot.data ?? 0;
                    return _CompassDial(
                      bearing: bearing,
                      heading: heading,
                      live: true,
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              headingStream == null
                  ? l10n.qiblaHeadingUnavailable
                  : l10n.qiblaPointDevice,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompassDial extends StatelessWidget {
  const _CompassDial({
    required this.bearing,
    required this.heading,
    required this.live,
  });

  final double bearing;
  final double heading;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Dial rotates so the device heading stays up; the needle points at the
    // qibla bearing relative to the current heading.
    final needleAngle = (bearing - heading) * pi / 180;
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: -heading * pi / 180,
          child: CustomPaint(
            size: const Size.square(280),
            painter: _DialPainter(color: colorScheme.outline),
          ),
        ),
        Transform.rotate(
          angle: needleAngle,
          child: CustomPaint(
            size: const Size.square(280),
            painter: _NeedlePainter(
              color: live ? colorScheme.primary : colorScheme.outline,
              label: context.l10n.qiblaKaabaShort,
            ),
          ),
        ),
        Icon(
          Icons.navigation_rounded,
          size: 32,
          color: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  const _DialPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final dialPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;
    final tickPaint = Paint()
      ..strokeWidth = 1.5
      ..color = color;
    canvas.drawCircle(center, radius, dialPaint);
    for (var degree = 0; degree < 360; degree += 2) {
      final isMajor = degree % 30 == 0;
      final angle = degree * pi / 180;
      final inner = radius - (isMajor ? 14 : 8);
      canvas.drawLine(
        center + Offset(sin(angle), -cos(angle)) * inner,
        center + Offset(sin(angle), -cos(angle)) * radius,
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) => oldDelegate.color != color;
}

class _NeedlePainter extends CustomPainter {
  const _NeedlePainter({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final needlePaint = Paint()..color = color;
    final tip = center - Offset(0, radius * 0.62);
    final left = center - Offset(radius * 0.06, 0);
    final right = center + Offset(radius * 0.06, 0);
    final tail = center + Offset(0, radius * 0.18);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(tail.dx, tail.dy)
        ..lineTo(right.dx, right.dy)
        ..close(),
      needlePaint,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_NeedlePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.label != label;
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
