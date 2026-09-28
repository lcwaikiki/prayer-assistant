import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../calendar/models/calendar_reminder.dart';
import '../../calendar/screens/hijri_calendar_screen.dart';
import '../../controller/prayer_app_controller.dart';
import '../../l10n/l10n.dart';
import '../../tesbihat/models/item.dart';
import '../../tesbihat/models/item_group.dart';
import '../../tesbihat/screens/execution_screen.dart';
import '../../tesbihat/screens/group_screen.dart';

enum UpcomingReminderType {
  calendar,
  bead,
  group,
}

class UpcomingReminder {
  const UpcomingReminder({
    required this.id,
    required this.title,
    required this.next,
    this.type = UpcomingReminderType.calendar,
    this.calendarReminder,
    this.bead,
    this.group,
  });

  final String id;
  final String title;
  final DateTime next;
  final UpcomingReminderType type;
  final CalendarReminder? calendarReminder;
  final Item? bead;
  final ItemGroup? group;

  CalendarReminder? get reminder => calendarReminder;
}

class UpcomingRemindersCard extends StatelessWidget {
  const UpcomingRemindersCard({super.key, required this.entries});

  final List<UpcomingReminder> entries;

  void _onTap(BuildContext context, UpcomingReminder entry) {
    switch (entry.type) {
      case UpcomingReminderType.calendar:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => HijriCalendarScreen(
              initialDate: entry.next,
              openDetailOnLaunch: true,
            ),
          ),
        );
      case UpcomingReminderType.bead:
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        try {
          context.read<PrayerAppController>().setTab(4);
        } catch (_) {}
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ExecutionScreen(itemId: entry.id),
          ),
        );
      case UpcomingReminderType.group:
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        try {
          context.read<PrayerAppController>().setTab(4);
        } catch (_) {}
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GroupScreen(groupId: entry.id),
          ),
        );
    }
  }

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
              onTap: () => _onTap(context, entry),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: Row(
                  children: [
                    Icon(
                      entry.type == UpcomingReminderType.bead
                          ? Icons.touch_app_outlined
                          : (entry.type == UpcomingReminderType.group
                              ? Icons.folder_outlined
                              : Icons.event_outlined),
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entry.title,
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
