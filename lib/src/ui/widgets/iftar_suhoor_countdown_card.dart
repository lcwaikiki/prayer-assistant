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

        final hours = (remainingSeconds ~/ 3600).toString().padLeft(2, '0');
        final minutes =
            ((remainingSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
        final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
        final timeDisplay = '$hours:$minutes:$seconds';

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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FastingScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_twilight,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${context.l10n.iftarTimeLabel}: $aksamStr',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timeDisplay,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      Chip(
                        avatar: Icon(
                          isFastingHours
                              ? Icons.local_fire_department
                              : Icons.bedtime,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
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
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Suhoor ($imsakStr)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% elapsed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        'Iftar ($aksamStr)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
