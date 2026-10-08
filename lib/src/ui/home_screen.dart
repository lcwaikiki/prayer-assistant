import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Consumer;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../calendar/models/calendar_reminder.dart';
import '../calendar/hijri_utils.dart';
import '../calendar/screens/hijri_calendar_screen.dart';
import '../calendar/screens/moon_calendar_screen.dart';
import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';
import '../l10n/prayer_names.dart';

import '../models/prayer_models.dart';
import '../utils/time_utils.dart';
import '../supplications/screens/supplications_screen.dart';
import '../supplications/services/wisdom_service.dart';
import '../supplications/widgets/daily_wisdom_card.dart';
import '../tesbihat/models/reminder_schedulable.dart';
import '../tesbihat/state/groups_notifier.dart';
import '../tesbihat/state/items_notifier.dart';
import 'location_screen.dart';
import 'reminder_settings_screen.dart';
import 'widgets/iftar_suhoor_countdown_card.dart';
import 'widgets/moon_phase_widget.dart';
import 'widgets/upcoming_reminders_card.dart';
import '../calendar/moon_phase_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.onShare});

  /// Injectable share action so tests can capture the shared text without
  /// touching the platform share sheet. Defaults to [SharePlus.instance].
  final void Function(String text)? onShare;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    ref.listenManual(itemsNotifierProvider, (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<PrayerAppController>().syncUpcomingRemindersWidget();
        }
      });
    });
    ref.listenManual(groupsNotifierProvider, (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<PrayerAppController>().syncUpcomingRemindersWidget();
        }
      });
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
    final beads = ref.watch(itemsNotifierProvider);
    final groups = ref.watch(groupsNotifierProvider);

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
          if (controller.hasNetworkError) {
            return _EmptyState(
              icon: Icons.wifi_off_outlined,
              title: context.l10n.noInternetTitle,
              subtitle: context.l10n.noInternetMessage,
              action: FilledButton.icon(
                onPressed: controller.isBusy
                    ? null
                    : () => controller.refreshPrayerData(forceSync: true),
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
            );
          }
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
        final upcomingReminders = <UpcomingReminder>[
          for (final reminder in controller.calendarReminders)
            if (reminder.enabled)
              if (reminder.nextOccurrenceFrom(_now) case final next?)
                UpcomingReminder(
                  id: reminder.id,
                  title: reminder.title,
                  next: next,
                  type: UpcomingReminderType.calendar,
                  calendarReminder: reminder,
                ),
          for (final bead in beads)
            if (bead.reminderEnabled)
              if (bead.toCalendarReminder().nextOccurrenceFrom(_now)
                  case final next?)
                UpcomingReminder(
                  id: bead.id,
                  title: bead.title,
                  next: next,
                  type: UpcomingReminderType.bead,
                  bead: bead,
                ),
          for (final group in groups)
            if (group.reminderEnabled)
              if (group.toCalendarReminder().nextOccurrenceFrom(_now)
                  case final next?)
                UpcomingReminder(
                  id: group.id,
                  title: group.title,
                  next: next,
                  type: UpcomingReminderType.group,
                  group: group,
                ),
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
                                     const SizedBox(width: 4),
                                     SubtleMoonIcon(
                                       phaseValue: getMoonPhase(
                                         day.date,
                                         hijriOffset: controller.hijriDateOffset,
                                       ).phaseValue,
                                       size: 13,
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
                      if (controller.showCardDailyWisdom && dailyWisdom != null) ...[
                        DailyWisdomCard(wisdom: dailyWisdom),
                        const SizedBox(height: 6),
                      ],
                      if (controller.showCardIftarSuhoor) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: IftarSuhoorCountdownCard(),
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (controller.showCardMoonPhase) ...[
                        MoonPhaseCard(
                          date: day.date,
                          hijriOffset: controller.hijriDateOffset,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => MoonCalendarScreen(initialDate: day.date),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (controller.showCardUpcomingReminders && upcoming.isNotEmpty) ...[
                        UpcomingRemindersCard(entries: upcoming),
                        const SizedBox(height: 6),
                      ],


                      // Prayer rows taking remaining vertical space
                      Expanded(
                        child: Card(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withAlpha(70),
                            ),
                          ),
                          child: Column(
                            children: [
                              for (final entry in prayerOrder.indexed) ...[
                                if (entry.$1 > 0)
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant
                                        .withAlpha(40),
                                  ),
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
                                        controller.togglePrayerCompletionForDate(
                                          entry.$2,
                                          day.date,
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
    final isFajr =
        name.toLowerCase() == 'imsak' || name.toLowerCase() == 'fajr';
    final hasReminder =
        reminderSetting.notifyOnTime ||
        reminderSetting.notifyBefore ||
        reminderSetting.notifyAfter ||
        (!isFajr && reminderSetting.silentMode);
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
          ? Colors.green.withAlpha(25)
          : (isNext ? colorScheme.primaryContainer.withAlpha(140) : null),
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
              : (isNext ? colorScheme.primary : colorScheme.outline),
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
                : (isNext ? colorScheme.primary : colorScheme.primary),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.prayerNameLabel(name),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
              color: isCompleted
                  ? Colors.green.shade700
                  : (isNext ? colorScheme.onSurface : null),
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
                              ? colorScheme.primary
                              : colorScheme.primary))
                    : (isCompleted ? Colors.green.shade300 : colorScheme.outline),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: isCompleted
                  ? Colors.green.shade700
                  : (isNext ? colorScheme.onSurface : null),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            size: 22,
            color: isCompleted
                ? Colors.green.shade300
                : (isNext ? colorScheme.primary : colorScheme.outlineVariant),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(160),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.play_arrow_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '${context.l10n.nextPrayerTitle}: ',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: context.l10n.prayerNameLabel(info.name),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat('HH:mm').format(info.time),
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.startsIn(formatRemaining(info.remaining)),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
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
