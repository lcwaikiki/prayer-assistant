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
    throw Exception(
      'Location service is disabled on this device. Please enable location services.',
    );
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
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
  ).timeout(const Duration(seconds: 5));
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
    return FlutterCompass.events
        ?.where((e) => e.heading != null)
        .map((e) => e.heading!)
        .handleError((_) {});
  } catch (_) {
    return null;
  }
}

class _QiblaScreenState extends State<QiblaScreen>
    with WidgetsBindingObserver {
  Stream<double>? _effectiveHeadingStream;
  late Future<({double lat, double lon})> _positionFuture;
  bool _hasResolvedPosition = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _effectiveHeadingStream =
        widget.headingStream ??
        (widget.compassStreamProvider ?? _defaultCompassStream)();
    _fetchPosition();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_hasResolvedPosition && mounted) {
      _fetchPosition();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _fetchPosition() {
    setState(() {
      _positionFuture = (widget.loadPosition?.call() ?? loadDevicePosition())
          .then((pos) {
        _hasResolvedPosition = true;
        return pos;
      }).catchError((error) {
        _hasResolvedPosition = false;
        throw error;
      });
    });
  }

  Future<void> _requestLocationPermission() async {
    try {
      if (widget.loadPosition == null) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          await Geolocator.openLocationSettings();
        } else {
          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          } else if (permission == LocationPermission.deniedForever) {
            await Geolocator.openAppSettings();
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      _fetchPosition();
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

class _QiblaViewState extends State<_QiblaView> with SingleTickerProviderStateMixin {
  bool _wasAligned = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutQuad,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _checkAlignmentHaptic(bool isAligned) {
    if (isAligned && !_wasAligned) {
      _wasAligned = true;
      _pulseController.repeat();
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
    } else if (!isAligned && _wasAligned) {
      _wasAligned = false;
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  static String _cardinalDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) % 360 / 45).floor();
    return directions[index];
  }

  String _makkahLocalTime() {
    final makkahNow = DateTime.now().toUtc().add(const Duration(hours: 3));
    final hour = makkahNow.hour.toString().padLeft(2, '0');
    final minute = makkahNow.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final distanceKm = distanceToMeccaKm(widget.lat, widget.lon).round();
    const emeraldColor = Color(0xFF10B981);

    final formattedDistance = distanceKm
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},');

    final sun = sunPosition(widget.lat, widget.lon);
    final sunAzimuth = sun.elevation > -0.833 ? sun.azimuth : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Location & Sensor Status Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.locationLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 1,
                      height: 12,
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Makkah ${_makkahLocalTime()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Qibla Target Bearing Title
              Text(
                l10n.qiblaBearing(widget.bearing.round()),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Compass Dial Area
              if (widget.headingStream == null)
                _CompassDial(
                  bearing: widget.bearing,
                  heading: 0,
                  live: false,
                  pulseAnimation: _pulseAnimation,
                  sunAzimuth: sunAzimuth,
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

                    final diffDegrees = ((widget.bearing - heading + 180) % 360 - 180).round();
                    final turnText = isAligned
                        ? l10n.qiblaAligned
                        : (diffDegrees > 0
                            ? l10n.qiblaTurnRight(diffDegrees.abs())
                            : l10n.qiblaTurnLeft(diffDegrees.abs()));

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CompassDial(
                          bearing: widget.bearing,
                          heading: heading,
                          live: true,
                          pulseAnimation: _pulseAnimation,
                          sunAzimuth: sunAzimuth,
                          onAlignmentChanged: _checkAlignmentHaptic,
                        ),
                        const SizedBox(height: 14),

                        // Alignment status pill
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: isAligned
                                ? emeraldColor.withValues(alpha: isDark ? 0.22 : 0.15)
                                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAligned
                                  ? emeraldColor.withValues(alpha: 0.7)
                                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                              width: isAligned ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAligned ? Icons.check_circle_rounded : Icons.sync_rounded,
                                size: 16,
                                color: isAligned ? emeraldColor : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                turnText,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isAligned ? emeraldColor : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

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

              // Guidance Helper Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.headingStream == null
                          ? Icons.info_outline_rounded
                          : Icons.screen_rotation_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.headingStream == null
                            ? l10n.qiblaHeadingUnavailable
                            : l10n.qiblaPointDevice,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isAligned
            ? emeraldColor.withValues(alpha: isDark ? 0.16 : 0.08)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAligned
              ? emeraldColor.withValues(alpha: 0.6)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: isAligned ? 1.5 : 1,
        ),
        boxShadow: [
          if (isAligned)
            BoxShadow(
              color: emeraldColor.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              label: l10n.qiblaHeading,
              value: currentHeading,
              icon: Icons.explore_rounded,
            ),
          ),
          Container(
            height: 36,
            width: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Expanded(
            child: _StatColumn(
              label: l10n.qiblaTitle,
              value: qiblaBearing,
              icon: Icons.navigation_rounded,
              valueColor: isAligned ? emeraldColor : null,
            ),
          ),
          Container(
            height: 36,
            width: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Expanded(
            child: _StatColumn(
              label: l10n.qiblaKaaba,
              value: distance,
              icon: Icons.mosque_rounded,
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
            Icon(icon, size: 13, color: theme.colorScheme.outline),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor ?? theme.colorScheme.onSurface,
              letterSpacing: -0.2,
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
    required this.pulseAnimation,
    required this.onAlignmentChanged,
    this.sunAzimuth,
  });

  final double bearing;
  final double heading;
  final bool live;
  final Animation<double> pulseAnimation;
  final ValueChanged<bool> onAlignmentChanged;
  final double? sunAzimuth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final needleAngle = (bearing - heading) * pi / 180;
    final diff = ((bearing - heading + 180) % 360 - 180).abs();
    final isAligned = live && diff <= 3.0;
    const emeraldColor = Color(0xFF10B981);

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        final pulseProgress = isAligned ? pulseAnimation.value : 0.0;
        return Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              if (isAligned) ...[
                BoxShadow(
                  color: emeraldColor.withValues(
                    alpha: (1.0 - pulseProgress) * (isDark ? 0.5 : 0.35),
                  ),
                  blurRadius: 28 + (pulseProgress * 24),
                  spreadRadius: 4 + (pulseProgress * 12),
                ),
                BoxShadow(
                  color: emeraldColor.withValues(alpha: isDark ? 0.4 : 0.25),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ] else ...[
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ],
          ),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Dial (Rotates with device heading to keep North pointing correctly)
          Transform.rotate(
            angle: -heading * pi / 180,
            child: CustomPaint(
              size: const Size.square(292),
              painter: _DialPainter(
                color: colorScheme.outlineVariant,
                textColor: colorScheme.onSurface,
                northColor: const Color(0xFFEF4444),
                goldColor: const Color(0xFFF59E0B),
                backgroundColor: isDark
                    ? const Color(0xFF131822)
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                isAligned: isAligned,
                qiblaBearing: bearing,
                sunAzimuth: sunAzimuth,
              ),
            ),
          ),

          // Qibla Direction Needle
          Transform.rotate(
            angle: needleAngle,
            child: CustomPaint(
              size: const Size.square(292),
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
                isDark: isDark,
              ),
            ),
          ),

          // Top Precision Sight Indicator with alignment glow
          Positioned(
            top: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: isAligned ? emeraldColor : colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: (isAligned ? emeraldColor : colorScheme.primary)
                        .withValues(alpha: isAligned ? 0.6 : 0.35),
                    blurRadius: isAligned ? 10 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),

          // Center Pivot Hub with metallic ring and jewel core
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAligned ? emeraldColor : colorScheme.primary,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
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
    required this.goldColor,
    required this.backgroundColor,
    required this.isAligned,
    required this.qiblaBearing,
    this.sunAzimuth,
  });

  final Color color;
  final Color textColor;
  final Color northColor;
  final Color goldColor;
  final Color backgroundColor;
  final bool isAligned;
  final double qiblaBearing;
  final double? sunAzimuth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    // Background Circle
    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;
    canvas.drawCircle(center, radius, bgPaint);

    // Inner subtle Islamic 8-point geometric star watermark
    _drawIslamicStarWatermark(canvas, center, radius * 0.46);

    // Outer Precision Rim
    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isAligned ? 2.5 : 1.8
      ..color = isAligned
          ? const Color(0xFF10B981).withValues(alpha: 0.9)
          : color.withValues(alpha: 0.6);
    canvas.drawCircle(center, radius - 1.5, outerRingPaint);

    // Inner Concentric Track Ring
    final innerTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.25);
    canvas.drawCircle(center, radius * 0.70, innerTrackPaint);

    // Target Qibla cone arc (±3 degrees) on dial
    final qiblaRad = qiblaBearing * pi / 180;
    final arcRect = Rect.fromCircle(center: center, radius: radius - 3);
    final conePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = (isAligned ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
          .withValues(alpha: isAligned ? 0.8 : 0.45);
    canvas.drawArc(arcRect, qiblaRad - pi / 2 - (3 * pi / 180), 6 * pi / 180, false, conePaint);

    // Precision Ticks around circumference
    final tickPaint = Paint()..strokeCap = StrokeCap.round;

    for (var degree = 0; degree < 360; degree += 2) {
      final isMajor = degree % 30 == 0;
      final isMedium = degree % 10 == 0;
      final isNorth = degree == 0;
      final angle = degree * pi / 180;

      final tickLength = isMajor ? 14.0 : (isMedium ? 9.0 : 5.0);
      final inner = radius - tickLength - 2;

      tickPaint.strokeWidth = isMajor ? 2.0 : (isMedium ? 1.3 : 0.8);
      tickPaint.color = isNorth
          ? northColor
          : (isMajor
              ? textColor.withValues(alpha: 0.85)
              : color.withValues(alpha: isMedium ? 0.7 : 0.35));

      canvas.drawLine(
        center + Offset(sin(angle), -cos(angle)) * inner,
        center + Offset(sin(angle), -cos(angle)) * (radius - 3),
        tickPaint,
      );
    }

    // Cardinal and Intercardinal Directions
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

      final labelRadius = radius - (isMajorCardinal ? 27 : 23);
      final pos = center + Offset(sin(angle), -cos(angle)) * labelRadius;

      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: isN
              ? northColor
              : (isMajorCardinal
                  ? textColor
                  : textColor.withValues(alpha: 0.5)),
          fontSize: isMajorCardinal ? 13 : 9,
          fontWeight: isMajorCardinal ? FontWeight.w800 : FontWeight.w600,
          letterSpacing: isMajorCardinal ? 0.5 : 0,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    // Sun Position Marker (when above horizon)
    if (sunAzimuth != null) {
      final sunRad = sunAzimuth! * pi / 180;
      final sunMarkerRadius = radius - 14;
      final sunPos = center + Offset(sin(sunRad), -cos(sunRad)) * sunMarkerRadius;

      final sunGlowPaint = Paint()
        ..color = const Color(0xFFFBBF24).withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(sunPos, 8, sunGlowPaint);

      final sunCorePaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(sunPos, 4, sunCorePaint);
    }

    // Kaaba Indicator Marker on the dial perimeter
    final kaabaMarkerRadius = radius - 14;
    final kaabaMarkerPos = center + Offset(sin(qiblaRad), -cos(qiblaRad)) * kaabaMarkerRadius;

    final markerGlowPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(kaabaMarkerPos, 8, markerGlowPaint);

    final markerDotPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(kaabaMarkerPos, 4, markerDotPaint);
  }

  void _drawIslamicStarWatermark(Canvas canvas, Offset center, double starRadius) {
    final starPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = textColor.withValues(alpha: 0.07);

    // 8-point geometric star created from two rotated squares
    final square1 = Path()
      ..addRect(Rect.fromCenter(
        center: center,
        width: starRadius * 2,
        height: starRadius * 2,
      ));

    canvas.drawPath(square1, starPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 4);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(square1, starPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.textColor != textColor ||
      oldDelegate.northColor != northColor ||
      oldDelegate.goldColor != goldColor ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.isAligned != isAligned ||
      oldDelegate.qiblaBearing != qiblaBearing ||
      oldDelegate.sunAzimuth != sunAzimuth;
}

class _NeedlePainter extends CustomPainter {
  const _NeedlePainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.label,
    required this.isAligned,
    this.isDark = false,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final String label;
  final bool isAligned;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final tip = center - Offset(0, radius * 0.78);
    final leftWing = center - Offset(radius * 0.08, 0);
    final rightWing = center + Offset(radius * 0.08, 0);
    final tail = center + Offset(0, radius * 0.22);

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

    // Subtle drop shadow / outline on the needle
    final needleOutlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.black.withValues(alpha: 0.15);
    canvas.drawPath(leftPath, needleOutlinePaint);
    canvas.drawPath(rightPath, needleOutlinePaint);

    // 3D Isometric Kaaba Monument on Pointer
    final kaabaSize = radius * 0.23;
    final kaabaCenter = tip + Offset(0, kaabaSize * 0.75);
    _drawIsometricKaaba(canvas, kaabaCenter, kaabaSize);
  }

  void _drawIsometricKaaba(Canvas canvas, Offset center, double size) {
    final w = size;
    final h = size * 0.85;
    final wallH = h * 0.65;

    // Top face vertices
    final topT = center + Offset(0, -h * 0.55);
    final topL = center + Offset(-w * 0.45, -h * 0.25);
    final topR = center + Offset(w * 0.45, -h * 0.25);
    final topB = center + Offset(0, 0);

    // Bottom face vertices
    final botL = topL + Offset(0, wallH);
    final botC = topB + Offset(0, wallH);
    final botR = topR + Offset(0, wallH);

    // Marble Base Plinth (Shadherwan) extending slightly beyond walls
    final plinthL = botL + Offset(-w * 0.05, h * 0.08);
    final plinthC = botC + Offset(0, h * 0.10);
    final plinthR = botR + Offset(w * 0.05, h * 0.08);

    // Base drop shadow
    final shadowPath = Path()
      ..moveTo(plinthL.dx, plinthL.dy)
      ..lineTo(plinthC.dx, plinthC.dy + 3)
      ..lineTo(plinthR.dx, plinthR.dy)
      ..lineTo(center.dx, plinthC.dy + 6)
      ..close();
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.6 : 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(shadowPath, shadowPaint);

    // White Marble Plinth (Shadherwan base)
    final plinthLeft = Path()
      ..moveTo(botL.dx, botL.dy)
      ..lineTo(botC.dx, botC.dy)
      ..lineTo(plinthC.dx, plinthC.dy)
      ..lineTo(plinthL.dx, plinthL.dy)
      ..close();
    final plinthRight = Path()
      ..moveTo(botR.dx, botR.dy)
      ..lineTo(botC.dx, botC.dy)
      ..lineTo(plinthC.dx, plinthC.dy)
      ..lineTo(plinthR.dx, plinthR.dy)
      ..close();

    final plinthPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9);
    canvas.drawPath(plinthLeft, plinthPaint);
    canvas.drawPath(
      plinthRight,
      Paint()
        ..style = PaintingStyle.fill
        ..color = isDark ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
    );

    // Left Face (Front Lighted Wall)
    final leftFace = Path()
      ..moveTo(topL.dx, topL.dy)
      ..lineTo(topB.dx, topB.dy)
      ..lineTo(botC.dx, botC.dy)
      ..lineTo(botL.dx, botL.dy)
      ..close();
    final leftFacePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? const Color(0xFF283344) : const Color(0xFF1E293B);
    canvas.drawPath(leftFace, leftFacePaint);

    // Right Face (Shaded Wall)
    final rightFace = Path()
      ..moveTo(topR.dx, topR.dy)
      ..lineTo(topB.dx, topB.dy)
      ..lineTo(botC.dx, botC.dy)
      ..lineTo(botR.dx, botR.dy)
      ..close();
    final rightFacePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? const Color(0xFF161E2C) : const Color(0xFF0F172A);
    canvas.drawPath(rightFace, rightFacePaint);

    // Outer Silhouette Outline (for high contrast in Dark Theme)
    final silhouettePath = Path()
      ..moveTo(topT.dx, topT.dy)
      ..lineTo(topR.dx, topR.dy)
      ..lineTo(botR.dx, botR.dy)
      ..lineTo(botC.dx, botC.dy)
      ..lineTo(botL.dx, botL.dy)
      ..lineTo(topL.dx, topL.dy)
      ..close();
    final silhouetteOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = isDark
          ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.2);
    canvas.drawPath(silhouettePath, silhouetteOutline);

    // Gold Kiswah Band (Left Face)
    final goldBandLeft = Path()
      ..moveTo(topL.dx, topL.dy + wallH * 0.18)
      ..lineTo(topB.dx, topB.dy + wallH * 0.18)
      ..lineTo(topB.dx, topB.dy + wallH * 0.34)
      ..lineTo(topL.dx, topL.dy + wallH * 0.34)
      ..close();
    final goldPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFF59E0B);
    canvas.drawPath(goldBandLeft, goldPaint);

    // Gold Kiswah Band (Right Face)
    final goldBandRight = Path()
      ..moveTo(topR.dx, topR.dy + wallH * 0.18)
      ..lineTo(topB.dx, topB.dy + wallH * 0.18)
      ..lineTo(topB.dx, topB.dy + wallH * 0.34)
      ..lineTo(topR.dx, topR.dy + wallH * 0.34)
      ..close();
    canvas.drawPath(goldBandRight, goldPaint);

    // Bab al-Kaaba (Golden Door on Front-Left Wall)
    final doorL = topL + Offset(w * 0.20, wallH * 0.36);
    final doorR = topL + Offset(w * 0.38, wallH * 0.36);
    final doorBotL = doorL + Offset(0, wallH * 0.56);
    final doorBotR = doorR + Offset(0, wallH * 0.56);

    final doorPath = Path()
      ..moveTo(doorL.dx, doorL.dy)
      ..lineTo(doorR.dx, doorR.dy + (topB.dy - topL.dy) * 0.35)
      ..lineTo(doorBotR.dx, doorBotR.dy + (topB.dy - topL.dy) * 0.35)
      ..lineTo(doorBotL.dx, doorBotL.dy)
      ..close();

    final doorGlowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFDE047);
    canvas.drawPath(doorPath, doorGlowPaint);

    // Door inner frame border
    final doorBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = const Color(0xFFB45309);
    canvas.drawPath(doorPath, doorBorderPaint);

    // Top Roof Face (White/Cream Marble Roof)
    final topFace = Path()
      ..moveTo(topT.dx, topT.dy)
      ..lineTo(topR.dx, topR.dy)
      ..lineTo(topB.dx, topB.dy)
      ..lineTo(topL.dx, topL.dy)
      ..close();
    final topFacePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFF1F5F9);
    canvas.drawPath(topFace, topFacePaint);

    final topEdgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = const Color(0xFF94A3B8);
    canvas.drawPath(topFace, topEdgePaint);
  }

  @override
  bool shouldRepaint(_NeedlePainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor ||
      oldDelegate.label != label ||
      oldDelegate.isAligned != isAligned ||
      oldDelegate.isDark != isDark;
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
