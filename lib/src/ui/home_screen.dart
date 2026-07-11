import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';
import '../models/prayer_models.dart';
import '../utils/time_utils.dart';

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
            title: 'No location selected',
            subtitle: 'Go to Location tab and save your district first.',
          );
        }

        final day = controller.today;
        if (day == null) {
          return _EmptyState(
            icon: Icons.schedule_outlined,
            title: 'No prayer times in cache',
            subtitle: 'Tap refresh to sync yearly data.',
            action: FilledButton.icon(
              onPressed: controller.isBusy
                  ? null
                  : () => controller.refreshPrayerData(forceSync: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
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
                    'Today • ${DateFormat('EEEE, dd MMM yyyy').format(day.date)}',
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
              day.hijriDate.isEmpty ? 'Hijri: -' : 'Hijri: ${day.hijriDate}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (nextPrayer != null) _NextPrayerCard(info: nextPrayer),
            const SizedBox(height: 16),
            ...prayerOrder.map(
              (name) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PrayerTile(name: name, value: prayers[name] ?? '--:--'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder Hooks',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Toggle reminders now. Notification engine can be plugged in later without changing UI.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    ...prayerOrder.map(
                      (name) => SwitchListTile(
                        dense: true,
                        title: Text(name),
                        contentPadding: EdgeInsets.zero,
                        value: controller.reminderSettings[name] ?? false,
                        onChanged: (value) =>
                            controller.setReminderEnabled(name, value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({required this.name, required this.value});

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.access_time),
        title: Text(name),
        trailing: Text(value, style: Theme.of(context).textTheme.titleLarge),
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
            Text('Next Prayer', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(info.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(DateFormat('HH:mm').format(info.time)),
            const SizedBox(height: 12),
            Text(
              'Starts in ${formatRemaining(info.remaining)}',
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
