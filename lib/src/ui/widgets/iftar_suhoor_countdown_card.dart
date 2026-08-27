import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/prayer_app_controller.dart';
import '../../l10n/l10n.dart';
import '../fasting_screen.dart';

class IftarSuhoorCountdownCard extends StatefulWidget {
  const IftarSuhoorCountdownCard({super.key});

  @override
  State<IftarSuhoorCountdownCard> createState() =>
      _IftarSuhoorCountdownCardState();
}

class _IftarSuhoorCountdownCardState extends State<IftarSuhoorCountdownCard> {
  Timer? _timer;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        final todayDay = controller.today;
        final imsakStr = todayDay?.imsak ?? '05:00';
        final aksamStr = todayDay?.aksam ?? '19:00';

        final now = DateTime.now();

        // Parse Fajr (Imsak) and Maghrib (Aksam) times for today
        DateTime? parseTime(String timeStr) {
          final parts = timeStr.split(':');
          if (parts.length != 2) return null;
          final h = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          if (h == null || m == null) return null;
          return DateTime(now.year, now.month, now.day, h, m);
        }

        final imsakTime = parseTime(imsakStr) ?? DateTime(now.year, now.month, now.day, 5, 0);
        final aksamTime = parseTime(aksamStr) ?? DateTime(now.year, now.month, now.day, 19, 0);

        final bool isFastingHours =
            now.isAfter(imsakTime) && now.isBefore(aksamTime);

        final DateTime targetTime;
        final String title;
        final IconData icon;

        if (isFastingHours) {
          targetTime = aksamTime;
          title = context.l10n.iftarCountdownTitle;
          icon = Icons.nights_stay;
        } else {
          // If after Aksam, target is tomorrow's Imsak
          if (now.isAfter(aksamTime)) {
            targetTime = imsakTime.add(const Duration(days: 1));
          } else {
            targetTime = imsakTime;
          }
          title = context.l10n.suhoorCountdownTitle;
          icon = Icons.wb_twilight;
        }

        final diff = targetTime.difference(now);
        final remainingSeconds = diff.inSeconds.clamp(0, 86400);

        final thresholdMinutes = controller.widgetMmssThresholdMinutes;
        final showSeconds = thresholdMinutes > 0 &&
            remainingSeconds <= thresholdMinutes * 60;

        final hours = remainingSeconds ~/ 3600;
        final minutes = (remainingSeconds % 3600) ~/ 60;
        final seconds = remainingSeconds % 60;

        final String timeDisplay;
        if (showSeconds) {
          if (hours > 0) {
            timeDisplay = '${hours.toString().padLeft(2, '0')}:'
                '${minutes.toString().padLeft(2, '0')}:'
                '${seconds.toString().padLeft(2, '0')}';
          } else {
            timeDisplay = '${minutes.toString().padLeft(2, '0')}:'
                '${seconds.toString().padLeft(2, '0')}';
          }
        } else {
          timeDisplay = '${hours.toString().padLeft(2, '0')}:'
              '${minutes.toString().padLeft(2, '0')}';
        }

        // Calculate progress percentage
        double progress = 0.0;
        if (isFastingHours) {
          final totalFastingSeconds =
              aksamTime.difference(imsakTime).inSeconds;
          if (totalFastingSeconds > 0) {
            final elapsed = now.difference(imsakTime).inSeconds;
            progress = (elapsed / totalFastingSeconds).clamp(0.0, 1.0);
          }
        } else {
          final prevAksam = aksamTime.isAfter(now)
              ? aksamTime.subtract(const Duration(days: 1))
              : aksamTime;
          final totalNightSeconds =
              targetTime.difference(prevAksam).inSeconds;
          if (totalNightSeconds > 0) {
            final elapsed = now.difference(prevAksam).inSeconds;
            progress = (elapsed / totalNightSeconds).clamp(0.0, 1.0);
          }
        }

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: theme.colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 13,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              title,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                            minWidth: 28, minHeight: 28),
                        padding: EdgeInsets.zero,
                        tooltip: context.l10n.fastingTitle,
                        icon: const Icon(Icons.open_in_new, size: 16),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const FastingScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  if (!_isExpanded) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeDisplay,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${context.l10n.iftarTimeLabel}: $aksamStr',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                  if (_isExpanded) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${context.l10n.iftarTimeLabel}: $aksamStr',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        Chip(
                          avatar: Icon(
                            isFastingHours
                                ? Icons.local_fire_department
                                : Icons.bedtime,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          label: Text(
                            isFastingHours
                                ? '${(progress * 100).round()}% Fasted'
                                : 'Suhoor Ticker',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeDisplay,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Suhoor ($imsakStr)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}% elapsed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Iftar ($aksamStr)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

