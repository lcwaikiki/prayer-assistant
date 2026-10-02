import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../l10n/l10n.dart';
import '../utils/qibla_utils.dart';

typedef QiblaPositionLoader = Future<({double lat, double lon})> Function();

Future<({double lat, double lon})> loadDevicePosition() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    throw Exception(
      'Location service is disabled on this device. Please enable location services.',
    );
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openAppSettings();
    throw Exception(
      'Location permission is permanently denied. Please enable it in Settings.',
    );
  }

  if (permission == LocationPermission.denied) {
    throw Exception('Location permission is required to detect your location.');
  }

  Position? position = await Geolocator.getLastKnownPosition();
  position ??= await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 5),
    ),
  );
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
  late Future<({double lat, double lon})> _positionFuture;

  @override
  void initState() {
    super.initState();
    _effectiveHeadingStream =
        widget.headingStream ??
        (widget.compassStreamProvider ?? _defaultCompassStream)();
    _positionFuture = widget.loadPosition?.call() ?? loadDevicePosition();
  }

  Future<void> _requestLocationPermission() async {
    try {
      if (widget.loadPosition == null) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          await Geolocator.openLocationSettings();
          return;
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        } else if (permission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _positionFuture = widget.loadPosition?.call() ?? loadDevicePosition();
      });
    }
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
            action: FilledButton.icon(
              onPressed: _requestLocationPermission,
              icon: const Icon(Icons.my_location),
              label: Text(context.l10n.grantLocationPermission),
            ),
          );
        }
        final bearing = qiblaBearing(position.lat, position.lon);
        return _QiblaView(
          bearing: bearing,
          headingStream: _effectiveHeadingStream,
          locationLabel:
              '${position.lat.toStringAsFixed(2)}, ${position.lon.toStringAsFixed(2)}',
          lat: position.lat,
          lon: position.lon,
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

class _QiblaView extends StatefulWidget {
  const _QiblaView({
    required this.bearing,
    required this.headingStream,
    required this.locationLabel,
    required this.lat,
    required this.lon,
  });

  final double bearing;
  final Stream<double>? headingStream;
  final String locationLabel;
  final double lat;
  final double lon;

  @override
  State<_QiblaView> createState() => _QiblaViewState();
}

class _QiblaViewState extends State<_QiblaView> {
  bool _wasAligned = false;

  void _checkAlignmentHaptic(bool isAligned) {
    if (isAligned && !_wasAligned) {
      _wasAligned = true;
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    } else if (!isAligned && _wasAligned) {
      _wasAligned = false;
    }
  }

  static String _cardinalDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) % 360 / 45).floor();
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final distanceKm = distanceToMeccaKm(widget.lat, widget.lon).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.locationLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.qiblaBearing(widget.bearing.round()),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.headingStream == null)
                _CompassDial(
                  bearing: widget.bearing,
                  heading: 0,
                  live: false,
                  onAlignmentChanged: (_) {},
                )
              else
                StreamBuilder<double>(
                  stream: widget.headingStream,
                  initialData: 0,
                  builder: (context, snapshot) {
                    final heading = snapshot.data ?? 0;
                    final diff = ((widget.bearing - heading + 180) % 360 - 180).abs();
                    final isAligned = diff <= 3.0;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _checkAlignmentHaptic(isAligned);
                      }
                    });

                    final formattedDistance = distanceKm
                        .toString()
                        .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (m) => '${m[1]},');

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CompassDial(
                          bearing: widget.bearing,
                          heading: heading,
                          live: true,
                          onAlignmentChanged: _checkAlignmentHaptic,
                        ),
                        const SizedBox(height: 16),
                        _InfoStatsRow(
                          currentHeading: '${heading.round()}° ${_cardinalDirection(heading)}',
                          qiblaBearing: '${widget.bearing.round()}° ${_cardinalDirection(widget.bearing)}',
                          distance: l10n.qiblaDistanceKm(formattedDistance),
                          isAligned: isAligned,
                        ),
                      ],
                    );
                  },
                ),
              if (widget.headingStream == null) ...[
                const SizedBox(height: 16),
                _InfoStatsRow(
                  currentHeading: '--',
                  qiblaBearing: '${widget.bearing.round()}° ${_cardinalDirection(widget.bearing)}',
                  distance: l10n.qiblaDistanceKm(distanceKm
                      .toString()
                      .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]},')),
                  isAligned: false,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                widget.headingStream == null
                    ? l10n.qiblaHeadingUnavailable
                    : l10n.qiblaPointDevice,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoStatsRow extends StatelessWidget {
  const _InfoStatsRow({
    required this.currentHeading,
    required this.qiblaBearing,
    required this.distance,
    required this.isAligned,
  });

  final String currentHeading;
  final String qiblaBearing;
  final String distance;
  final bool isAligned;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const emeraldColor = Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAligned
            ? emeraldColor.withValues(alpha: isDark ? 0.18 : 0.1)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAligned
              ? emeraldColor.withValues(alpha: 0.6)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: isAligned ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              label: l10n.qiblaHeading,
              value: currentHeading,
              icon: Icons.explore_outlined,
            ),
          ),
          Container(
            height: 32,
            width: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          Expanded(
            child: _StatColumn(
              label: l10n.qiblaTitle,
              value: qiblaBearing,
              icon: Icons.navigation_outlined,
              valueColor: isAligned ? emeraldColor : null,
            ),
          ),
          Container(
            height: 32,
            width: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          Expanded(
            child: _StatColumn(
              label: l10n.qiblaKaaba,
              value: distance,
              icon: Icons.mosque_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: theme.colorScheme.outline),
            const SizedBox(width: 3),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompassDial extends StatelessWidget {
  const _CompassDial({
    required this.bearing,
    required this.heading,
    required this.live,
    required this.onAlignmentChanged,
  });

  final double bearing;
  final double heading;
  final bool live;
  final ValueChanged<bool> onAlignmentChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final needleAngle = (bearing - heading) * pi / 180;
    final diff = ((bearing - heading + 180) % 360 - 180).abs();
    final isAligned = live && diff <= 3.0;
    const emeraldColor = Color(0xFF10B981);

    return Container(
      width: 290,
      height: 290,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (isAligned)
            BoxShadow(
              color: emeraldColor.withValues(alpha: isDark ? 0.35 : 0.25),
              blurRadius: 28,
              spreadRadius: 4,
            )
          else
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -heading * pi / 180,
            child: CustomPaint(
              size: const Size.square(280),
              painter: _DialPainter(
                color: colorScheme.outlineVariant,
                textColor: colorScheme.onSurface,
                northColor: colorScheme.error,
                backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: isDark ? 0.4 : 0.25,
                ),
                isAligned: isAligned,
              ),
            ),
          ),
          Transform.rotate(
            angle: needleAngle,
            child: CustomPaint(
              size: const Size.square(280),
              painter: _NeedlePainter(
                primaryColor: isAligned
                    ? emeraldColor
                    : (live ? colorScheme.primary : colorScheme.outline),
                secondaryColor: isAligned
                    ? const Color(0xFF059669)
                    : (live
                        ? colorScheme.primary.withValues(alpha: 0.75)
                        : colorScheme.outlineVariant),
                label: context.l10n.qiblaKaabaShort,
                isAligned: isAligned,
              ),
            ),
          ),
          Positioned(
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isAligned ? emeraldColor : colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAligned ? emeraldColor : colorScheme.primary,
              border: Border.all(
                color: Colors.white,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  const _DialPainter({
    required this.color,
    required this.textColor,
    required this.northColor,
    required this.backgroundColor,
    required this.isAligned,
  });

  final Color color;
  final Color textColor;
  final Color northColor;
  final Color backgroundColor;
  final bool isAligned;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;
    canvas.drawCircle(center, radius, bgPaint);

    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = isAligned
          ? const Color(0xFF10B981).withValues(alpha: 0.8)
          : color.withValues(alpha: 0.6);
    canvas.drawCircle(center, radius - 1, outerRingPaint);

    final innerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.3);
    canvas.drawCircle(center, radius * 0.72, innerRingPaint);

    final tickPaint = Paint()..strokeWidth = 1.2;

    for (var degree = 0; degree < 360; degree += 2) {
      final isMajor = degree % 30 == 0;
      final isMedium = degree % 10 == 0;
      final isNorth = degree == 0;
      final angle = degree * pi / 180;

      final tickLength = isMajor ? 14.0 : (isMedium ? 9.0 : 5.0);
      final inner = radius - tickLength;

      tickPaint.strokeWidth = isMajor ? 2.0 : (isMedium ? 1.4 : 0.8);
      tickPaint.color = isNorth
          ? northColor
          : (isMajor
              ? textColor.withValues(alpha: 0.8)
              : color.withValues(alpha: isMedium ? 0.7 : 0.4));

      canvas.drawLine(
        center + Offset(sin(angle), -cos(angle)) * inner,
        center + Offset(sin(angle), -cos(angle)) * (radius - 2),
        tickPaint,
      );
    }

    const cardinals = {
      0: 'N',
      45: 'NE',
      90: 'E',
      135: 'SE',
      180: 'S',
      225: 'SW',
      270: 'W',
      315: 'NW',
    };

    for (final entry in cardinals.entries) {
      final deg = entry.key;
      final text = entry.value;
      final angle = deg * pi / 180;
      final isMajorCardinal = deg % 90 == 0;
      final isN = deg == 0;

      final labelRadius = radius - (isMajorCardinal ? 26 : 22);
      final pos = center + Offset(sin(angle), -cos(angle)) * labelRadius;

      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: isN
              ? northColor
              : (isMajorCardinal
                  ? textColor
                  : textColor.withValues(alpha: 0.55)),
          fontSize: isMajorCardinal ? 13 : 9,
          fontWeight: isMajorCardinal ? FontWeight.bold : FontWeight.w500,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.textColor != textColor ||
      oldDelegate.northColor != northColor ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.isAligned != isAligned;
}

class _NeedlePainter extends CustomPainter {
  const _NeedlePainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.label,
    required this.isAligned,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final String label;
  final bool isAligned;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final tip = center - Offset(0, radius * 0.78);
    final leftWing = center - Offset(radius * 0.08, 0);
    final rightWing = center + Offset(radius * 0.08, 0);
    final tail = center + Offset(0, radius * 0.24);

    final leftPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(leftWing.dx, leftWing.dy)
      ..lineTo(tail.dx, tail.dy)
      ..close();

    final rightPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(rightWing.dx, rightWing.dy)
      ..lineTo(tail.dx, tail.dy)
      ..close();

    final leftPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor;

    final rightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = secondaryColor;

    canvas.drawPath(leftPath, leftPaint);
    canvas.drawPath(rightPath, rightPaint);

    final kaabaBoxSize = radius * 0.18;
    final kaabaCenter = tip + Offset(0, kaabaBoxSize * 0.9);
    final kaabaRect = Rect.fromCenter(
      center: kaabaCenter,
      width: kaabaBoxSize,
      height: kaabaBoxSize,
    );

    final kaabaPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(kaabaRect, const Radius.circular(3)),
      kaabaPaint,
    );

    final goldPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    final goldBandRect = Rect.fromLTWH(
      kaabaRect.left,
      kaabaRect.top + kaabaRect.height * 0.22,
      kaabaRect.width,
      kaabaRect.height * 0.18,
    );
    canvas.drawRect(goldBandRect, goldPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      kaabaCenter - Offset(textPainter.width / 2, textPainter.height / 2 - 1),
    );
  }

  @override
  bool shouldRepaint(_NeedlePainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor ||
      oldDelegate.label != label ||
      oldDelegate.isAligned != isAligned;
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.icon,
    this.action,
  });

  final String message;
  final IconData icon;
  final Widget? action;

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
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
