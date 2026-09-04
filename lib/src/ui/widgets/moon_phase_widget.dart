import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../calendar/moon_phase_utils.dart';
import '../../l10n/l10n.dart';

/// CustomPainter for rendering realistic 2D vector Moon phases.
class MoonPhasePainter extends CustomPainter {
  MoonPhasePainter({
    required this.phaseValue,
    this.moonColor = const Color(0xFFFDE047),
    this.shadowColor = const Color(0xFF1E293B),
    this.glowColor,
  });

  /// Phase value from 0.0 to 1.0.
  final double phaseValue;

  /// Color of the illuminated portion of the moon.
  final Color moonColor;

  /// Color of the dark shadow portion of the moon.
  final Color shadowColor;

  /// Optional glow color around the moon.
  final Color? glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // 1. Draw soft outer glow if full or near full moon
    final glow = glowColor ?? moonColor.withValues(alpha: 0.3);
    if (phaseValue > 0.35 && phaseValue < 0.65) {
      final glowPaint = Paint()
        ..color = glow
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.4);
      canvas.drawCircle(center, radius * 1.05, glowPaint);
    }

    // 2. Draw base dark moon disk
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, shadowPaint);

    // 3. Draw light portion depending on phase
    final lightPaint = Paint()
      ..color = moonColor
      ..style = PaintingStyle.fill;

    // Normalizing phase to [0, 1]
    final p = phaseValue % 1.0;

    final path = Path();

    if (p < 0.01 || p > 0.99) {
      // New Moon: completely dark, only draw a faint rim line
      final rimPaint = Paint()
        ..color = moonColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, radius, rimPaint);
      return;
    } else if (p > 0.49 && p < 0.51) {
      // Full Moon: completely light
      canvas.drawCircle(center, radius, lightPaint);
      return;
    }

    final isWaxing = p < 0.5;
    // Map phase to angle range: 0 -> -PI (New), 0.25 -> 0 (1st Qtr), 0.5 -> PI (Full)
    // Illumination curve x-radius multiplier:
    // Cosine of phase angle gives the ellipse width ratio for terminator line
    final phaseAngle = p * 2.0 * math.pi;
    final terminatorX = math.cos(phaseAngle) * radius;

    final rect = Rect.fromCircle(center: center, radius: radius);

    if (isWaxing) {
      // Right half is illuminated, terminator curves
      path.addArc(rect, -math.pi / 2, math.pi); // Right semicircle arc
      // Curve back along the terminator line
      final controlX = center.dx + terminatorX;
      path.cubicTo(
        controlX, center.dy + radius * 0.55,
        controlX, center.dy - radius * 0.55,
        center.dx, center.dy - radius,
      );
    } else {
      // Left half is illuminated, terminator curves
      path.addArc(rect, math.pi / 2, math.pi); // Left semicircle arc
      // Curve back along the terminator line
      final controlX = center.dx - terminatorX;
      path.cubicTo(
        controlX, center.dy - radius * 0.55,
        controlX, center.dy + radius * 0.55,
        center.dx, center.dy + radius,
      );
    }

    canvas.drawPath(path, lightPaint);

    // Faint outer border outline
    final borderPaint = Paint()
      ..color = moonColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant MoonPhasePainter oldDelegate) {
    return oldDelegate.phaseValue != phaseValue ||
        oldDelegate.moonColor != moonColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}

/// Compact Moon icon matching exact current phase for inline headers and calendar tiles.
class SubtleMoonIcon extends StatelessWidget {
  const SubtleMoonIcon({
    super.key,
    required this.phaseValue,
    this.size = 16,
    this.color,
  });

  final double phaseValue;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lightColor = color ?? (theme.brightness == Brightness.dark ? const Color(0xFFFDE047) : const Color(0xFFD97706));
    final darkColor = theme.brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return CustomPaint(
      size: Size(size, size),
      painter: MoonPhasePainter(
        phaseValue: phaseValue,
        moonColor: lightColor,
        shadowColor: darkColor,
      ),
    );
  }
}

/// Rich Card displaying full Moon Phase info, vector moon graphic, illumination %, and White Days alert.
class MoonPhaseCard extends StatelessWidget {
  const MoonPhaseCard({
    super.key,
    required this.date,
    this.hijriOffset = 0,
    this.onTap,
  });

  final DateTime date;
  final int hijriOffset;
  final VoidCallback? onTap;

  String _resolvePhaseName(BuildContext context, String key) {
    final l10n = context.l10n;
    switch (key) {
      case 'moonPhaseNewMoon':
        return l10n.moonPhaseNewMoon;
      case 'moonPhaseWaxingCrescent':
        return l10n.moonPhaseWaxingCrescent;
      case 'moonPhaseFirstQuarter':
        return l10n.moonPhaseFirstQuarter;
      case 'moonPhaseWaxingGibbous':
        return l10n.moonPhaseWaxingGibbous;
      case 'moonPhaseFullMoon':
        return l10n.moonPhaseFullMoon;
      case 'moonPhaseWaningGibbous':
        return l10n.moonPhaseWaningGibbous;
      case 'moonPhaseLastQuarter':
        return l10n.moonPhaseLastQuarter;
      case 'moonPhaseWaningCrescent':
        return l10n.moonPhaseWaningCrescent;
      default:
        return l10n.moonPhaseTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = getMoonPhase(date, hijriOffset: hijriOffset);
    final theme = Theme.of(context);
    final phaseName = _resolvePhaseName(context, info.phaseNameKey);
    final isDark = theme.brightness == Brightness.dark;

    final moonColor = isDark ? const Color(0xFFFDE047) : const Color(0xFFF59E0B);
    final shadowColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: info.isWhiteDay
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Vector Moon render
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CustomPaint(
                      painter: MoonPhasePainter(
                        phaseValue: info.phaseValue,
                        moonColor: moonColor,
                        shadowColor: shadowColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              phaseName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (info.isWhiteDay) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Day ${info.whiteDayNumber}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${context.l10n.moonIllumination(info.illumination.round())} • ${context.l10n.moonAgeDays(info.ageInDays.toStringAsFixed(1))}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // White Days Sunnah Banner if applicable
              if (info.isWhiteDay) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.brightness_5_outlined,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          context.l10n.whiteDaysTitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
