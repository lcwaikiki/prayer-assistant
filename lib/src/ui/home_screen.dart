import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../calendar/models/calendar_reminder.dart';
import '../calendar/screens/hijri_calendar_screen.dart';
import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';
import '../models/prayer_models.dart';
import '../utils/time_utils.dart';
import 'reminder_settings_screen.dart';

typedef _UpcomingReminder = ({CalendarReminder reminder, DateTime next});

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onShare});

  /// Injectable share action so tests can capture the shared text without
  /// touching the platform share sheet. Defaults to [SharePlus.instance].
  final void Function(String text)? onShare;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
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
        final selected = controller.selectedLocation;
        if (selected == null) {
          return _EmptyState(
            icon: Icons.location_off_outlined,
            title: context.l10n.homeNoLocationTitle,
            subtitle: context.l10n.homeNoLocationSubtitle,
          );
        }

        final day = controller.today;
        if (day == null) {
          return _EmptyState(
            icon: Icons.schedule_outlined,
            title: context.l10n.homeNoPrayerTimesTitle,
            subtitle: context.l10n.homeNoPrayerTimesSubtitle,
            action: FilledButton.icon(
              onPressed: controller.isBusy
                  ? null
                  : () => controller.refreshPrayerData(forceSync: true),
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.refresh),
            ),
          );
        }

        final nextPrayer = controller.nextPrayer(_now);
        final prayers = prayerMapForDay(day);
        final upcomingReminders = <_UpcomingReminder>[
          for (final reminder in controller.calendarReminders)
            if (reminder.enabled)
              if (reminder.nextOccurrenceFrom(_now) case final next?)
                (reminder: reminder, next: next),
        ]..sort((a, b) => a.next.compareTo(b.next));
        final upcoming = upcomingReminders.take(3).toList(growable: false);

        const outerPadding = 16.0;
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(outerPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - outerPadding * 2,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.todayWithDate(
                                DateFormat(
                                  'EEEE, dd MMM yyyy',
                                ).format(day.date),
                              ),
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: context.l10n.shareTodayTimes,
                            onPressed: () {
                              final text = buildSharePrayerTimesText(
                                location: selected,
                                day: day,
                                label: context.l10n.prayerNameLabel,
                              );
                              final onShare = widget.onShare;
                              if (onShare != null) {
                                onShare(text);
                              } else {
                                SharePlus.instance.share(
                                  ShareParams(text: text),
                                );
                              }
                            },
                            icon: const Icon(Icons.share_outlined),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: controller.isBusy
                                ? null
                                : () => controller.refreshPrayerData(
                                    forceSync: true,
                                  ),
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      Text(
                        '${selected.fullName} · ${day.hijriDate.isEmpty ? context.l10n.hijriUnknown : context.l10n.hijriWithDate(day.hijriDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      if (nextPrayer != null)
                        _NextPrayerBanner(info: nextPrayer),
                      const SizedBox(height: 10),
                      if (upcoming.isNotEmpty) ...[
                        _UpcomingRemindersCard(entries: upcoming),
                        const SizedBox(height: 10),
                      ],
                      Expanded(
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (final entry in prayerOrder.indexed) ...[
                                if (entry.$1 > 0) const Divider(height: 1),
                                Expanded(
                                  child: _CompactPrayerRow(
                                    name: entry.$2,
                                    value: prayers[entry.$2] ?? '--:--',
                                    reminderSetting: controller.reminderFor(
                                      entry.$2,
                                    ),
                                    isNext: entry.$2 == nextPrayer?.name,
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              ReminderSettingsScreen(
                                                prayerName: entry.$2,
                                              ),
                                        ),
                                      );
                                    },
                                    onToggleReminder: () =>
                                        controller.updateReminderSetting(
                                          prayer: entry.$2,
                                          notifyOnTime: !controller
                                              .reminderFor(entry.$2)
                                              .notifyOnTime,
                                        ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CompactPrayerRow extends StatelessWidget {
  const _CompactPrayerRow({
    required this.name,
    required this.value,
    required this.reminderSetting,
    required this.isNext,
    required this.onTap,
    required this.onToggleReminder,
  });

  final String name;
  final String value;
  final ReminderSetting reminderSetting;
  final bool isNext;
  final VoidCallback onTap;
  final VoidCallback onToggleReminder;

  @override
  Widget build(BuildContext context) {
    final hasReminder =
        reminderSetting.notifyOnTime || reminderSetting.notifyBefore;
    String statusText;
    if (reminderSetting.notifyOnTime && reminderSetting.notifyBefore) {
      statusText = context.l10n.reminderOnTimeAndBefore(
        reminderSetting.minutesBefore,
      );
    } else if (reminderSetting.notifyOnTime) {
      statusText = context.l10n.reminderOnTimeOnly;
    } else if (reminderSetting.notifyBefore) {
      statusText = context.l10n.reminderBeforeOnly(
        reminderSetting.minutesBefore,
      );
    } else {
      statusText = context.l10n.reminderOff;
    }
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      tileColor: isNext ? colorScheme.primaryContainer : null,
      onTap: onTap,
      leading: Icon(
        Icons.access_time,
        size: 26,
        color: isNext ? colorScheme.onPrimaryContainer : null,
      ),
      title: Text(
        context.l10n.prayerNameLabel(name),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isNext ? colorScheme.onPrimaryContainer : null,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: statusText,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onToggleReminder,
              icon: Icon(
                hasReminder
                    ? Icons.notifications_active
                    : Icons.notifications_off_outlined,
                size: 22,
                color: hasReminder
                    ? (isNext
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.primary)
                    : colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: isNext ? colorScheme.onPrimaryContainer : null,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            size: 22,
            color: isNext ? colorScheme.onPrimaryContainer : null,
          ),
        ],
      ),
    );
  }
}

class _NextPrayerBanner extends StatelessWidget {
  const _NextPrayerBanner({required this.info});

  final NextPrayerInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.play_arrow_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(text: '${context.l10n.nextPrayerTitle}: '),
                  TextSpan(
                    text: context.l10n.prayerNameLabel(info.name),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat('HH:mm').format(info.time),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.startsIn(formatRemaining(info.remaining)),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingRemindersCard extends StatelessWidget {
  const _UpcomingRemindersCard({required this.entries});

  final List<_UpcomingReminder> entries;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('EEE, d MMM · HH:mm', locale);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Text(
              context.l10n.homeUpcomingRemindersTitle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          for (final entry in entries)
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.event_outlined),
              title: Text(
                entry.reminder.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(dateFormat.format(entry.next)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => HijriCalendarScreen(
                      initialDate: entry.next,
                      openDetailOnLaunch: true,
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 14), action!],
          ],
        ),
      ),
    );
  }
}
