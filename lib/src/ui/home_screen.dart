import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../calendar/models/calendar_reminder.dart';
import '../calendar/hijri_utils.dart';
import '../calendar/screens/hijri_calendar_screen.dart';
import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';
import '../l10n/prayer_names.dart';

import '../models/prayer_models.dart';
import '../utils/time_utils.dart';
import '../supplications/screens/supplications_screen.dart';
import '../supplications/services/wisdom_service.dart';
import '../supplications/widgets/daily_wisdom_card.dart';
import 'location_screen.dart';
import 'reminder_settings_screen.dart';
import 'widgets/iftar_suhoor_countdown_card.dart';


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
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
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
    final dailyWisdom = WisdomService.instance.getWisdomForDate(_now);

    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        final selected = controller.selectedLocation;
        if (selected == null) {
          return _EmptyState(
            icon: Icons.location_off_outlined,
            title: context.l10n.homeNoLocationTitle,
            subtitle: context.l10n.homeNoLocationSubtitle,
            action: IconButton(
              tooltip: context.l10n.selectYourLocation,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    appBar: AppBar(
                      title: Text(context.l10n.tabLocation),
                    ),
                    body: const LocationScreen(),
                  ),
                ),
              ),
              icon: const Icon(Icons.refresh),
            ),
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

        const outerPadding = 12.0;
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(outerPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - outerPadding * 2,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top Header Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat(
                                    'EEEE, dd MMM yyyy',
                                    Localizations.localeOf(context).toString(),
                                  ).format(day.date),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        '${selected.districtName} · ${formatHijriDate(day.date, Localizations.localeOf(context).languageCode)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            tooltip: context.l10n.hisnAlMuslimTitle,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SupplicationsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.menu_book_outlined, size: 18),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            tooltip: context.l10n.shareTodayTimes,
                            onPressed: () {
                              final text = buildSharePrayerTimesText(
                                location: selected,
                                day: day,
                                label: context.l10n.prayerNameLabel,
                                locale: Localizations.localeOf(context)
                                    .languageCode,
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
                            icon: const Icon(Icons.share_outlined, size: 18),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            onPressed: controller.isBusy
                                ? null
                                : () => controller.refreshPrayerData(
                                    forceSync: true,
                                  ),
                            icon: const Icon(Icons.refresh, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Sub-header stats row
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.prayersCompleted(
                              controller.completedCountForDate(day.date),
                              6,
                            ),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      if (nextPrayer != null) ...[
                        _NextPrayerBanner(info: nextPrayer),
                        const SizedBox(height: 6),
                      ],
                      if (dailyWisdom != null) ...[
                        DailyWisdomCard(wisdom: dailyWisdom),
                        const SizedBox(height: 6),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        child: IftarSuhoorCountdownCard(),
                      ),
                      const SizedBox(height: 6),
                      if (upcoming.isNotEmpty) ...[
                        _UpcomingRemindersCard(entries: upcoming),
                        const SizedBox(height: 6),
                      ],


                      // Prayer rows taking remaining vertical space
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
                                    isCompleted: controller.isPrayerCompleted(
                                      entry.$2,
                                      day.date,
                                    ),
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
                                    onToggleCompleted: () =>
                                        controller.togglePrayerCompletion(
                                          entry.$2,
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
    required this.isCompleted,
    required this.onTap,
    required this.onToggleReminder,
    required this.onToggleCompleted,
  });

  final String name;
  final String value;
  final ReminderSetting reminderSetting;
  final bool isNext;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onToggleReminder;
  final VoidCallback onToggleCompleted;

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
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      tileColor: isCompleted
          ? Colors.green.withAlpha(30)
          : (isNext ? colorScheme.primaryContainer : null),
      onTap: onTap,
      leading: IconButton(
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
        onPressed: onToggleCompleted,
        icon: Icon(
          isCompleted ? Icons.check_circle : Icons.circle_outlined,
          size: 22,
          color: isCompleted
              ? Colors.green
              : (isNext ? colorScheme.onPrimaryContainer : null),
        ),
      ),

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconForPrayer(name),
            size: 18,
            color: isCompleted
                ? Colors.green.shade700
                : (isNext ? colorScheme.onPrimaryContainer : colorScheme.primary),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.prayerNameLabel(name),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isCompleted
                  ? Colors.green.shade700
                  : (isNext ? colorScheme.onPrimaryContainer : null),
            ),
          ),
        ],
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
                    ? (isCompleted
                          ? Colors.green.shade700
                          : (isNext
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.primary))
                    : (isCompleted ? Colors.green.shade300 : colorScheme.outline),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: isCompleted
                  ? Colors.green.shade700
                  : (isNext ? colorScheme.onPrimaryContainer : null),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            size: 22,
            color: isCompleted
                ? Colors.green.shade300
                : (isNext ? colorScheme.onPrimaryContainer : null),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.play_arrow_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
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
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              DateFormat('HH:mm').format(info.time),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            context.l10n.startsIn(formatRemaining(info.remaining)),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 2),
            child: Text(
              context.l10n.homeUpcomingRemindersTitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (final entry in entries)
            InkWell(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entry.reminder.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(entry.next),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 2),


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
