import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';
import '../models/prayer_models.dart';
import '../utils/time_utils.dart';
import 'reminder_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.todayWithDate(
                      DateFormat('EEEE, dd MMM yyyy').format(day.date),
                    ),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: controller.isBusy
                      ? null
                      : () => controller.refreshPrayerData(forceSync: false),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              selected.fullName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              day.hijriDate.isEmpty
                  ? context.l10n.hijriUnknown
                  : context.l10n.hijriWithDate(day.hijriDate),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (nextPrayer != null) _NextPrayerCard(info: nextPrayer),
            const SizedBox(height: 16),
            ...prayerOrder.map(
              (name) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PrayerTile(
                  name: name,
                  value: prayers[name] ?? '--:--',
                  reminderSetting: controller.reminderFor(name),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ReminderSettingsScreen(prayerName: name),
                      ),
                    );
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(context.l10n.reminderSettingsTitle),
                subtitle: Text(context.l10n.reminderSettingsSubtitle),
                trailing: IconButton(
                  tooltip: context.l10n.tooltipScheduledDebug,
                  icon: const Icon(Icons.bug_report_outlined),
                  onPressed: () =>
                      _showScheduledRemindersDebug(context, controller),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showScheduledRemindersDebug(
    BuildContext context,
    PrayerAppController controller,
  ) async {
    final entries = await controller.getScheduledReminders();
    if (!context.mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final now = DateTime.now();
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.scheduledRemindersDebugTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.pendingNotificationsCount(entries.length),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await controller.sendTestNotificationNow();
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.l10n.testNotificationSent)),
                      );
                    },
                    icon: const Icon(Icons.notification_add_outlined),
                    label: Text(context.l10n.sendTestNotificationNow),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.statusBarMinutesTitle),
                    subtitle: Text(context.l10n.statusBarMinutesSubtitle),
                    value: controller.statusBarRemainingEnabled,
                    onChanged: (value) =>
                        controller.updateStatusBarRemainingEnabled(value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.statusAutoRestoreTitle),
                    subtitle: Text(context.l10n.statusAutoRestoreSubtitle),
                    value: controller.statusBarAutoRestore,
                    onChanged: controller.statusBarRemainingEnabled
                        ? (value) => controller.updateStatusBarAutoRestore(value)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: entries.isEmpty
                        ? Center(
                            child: Text(context.l10n.noPendingReminders),
                          )
                        : ListView.separated(
                            itemCount: entries.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              final date = entry.scheduledAt;
                              final dateText = date == null
                                  ? context.l10n.unknownFireTime
                                  : DateFormat(
                                      'EEE, dd MMM HH:mm',
                                    ).format(date);
                              final isPast = date != null && date.isBefore(now);
                              return ListTile(
                                dense: true,
                                title: Text(entry.title),
                                subtitle: Text(
                                  '${isPast ? context.l10n.pastPrefix : ''}$dateText\n${entry.body}',
                                ),
                              );
                            },
                          ),
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

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({
    required this.name,
    required this.value,
    required this.reminderSetting,
    required this.onTap,
  });

  final String name;
  final String value;
  final ReminderSetting reminderSetting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String statusText;
    if (reminderSetting.notifyOnTime && reminderSetting.notifyBefore) {
      statusText = context.l10n.reminderOnTimeAndBefore(
        reminderSetting.minutesBefore,
      );
    } else if (reminderSetting.notifyOnTime) {
      statusText = context.l10n.reminderOnTimeOnly;
    } else if (reminderSetting.notifyBefore) {
      statusText = context.l10n.reminderBeforeOnly(reminderSetting.minutesBefore);
    } else {
      statusText = context.l10n.reminderOff;
    }
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.access_time),
        title: Text(name),
        subtitle: Text(statusText),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({required this.info});

  final NextPrayerInfo info;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.nextPrayerTitle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(info.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(DateFormat('HH:mm').format(info.time)),
            const SizedBox(height: 12),
            Text(
              context.l10n.startsIn(formatRemaining(info.remaining)),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
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
