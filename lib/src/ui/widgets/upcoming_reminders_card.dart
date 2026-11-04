import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;

import '../../calendar/models/calendar_reminder.dart';
import '../../calendar/screens/calendar_reminder_form_screen.dart';
import '../../controller/prayer_app_controller.dart';
import '../../l10n/l10n.dart';
import '../../tesbihat/models/item.dart';
import '../../tesbihat/models/item_group.dart';
import '../../tesbihat/screens/group_form_screen.dart';
import '../../tesbihat/screens/item_form_screen.dart';
import '../../tesbihat/state/groups_notifier.dart';
import '../../tesbihat/state/items_notifier.dart';
import '../../utils/orientation_utils.dart';

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

class UpcomingRemindersCard extends ConsumerWidget {
  const UpcomingRemindersCard({super.key, required this.entries});

  final List<UpcomingReminder> entries;

  void _onTap(BuildContext context, WidgetRef ref, UpcomingReminder entry) {
    switch (entry.type) {
      case UpcomingReminderType.calendar:
        final reminder = entry.calendarReminder ??
            (() {
              try {
                return provider.Provider.of<PrayerAppController>(context, listen: false)
                    .calendarReminders
                    .where((r) => r.id == entry.id)
                    .firstOrNull;
              } catch (_) {
                return null;
              }
            })();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CalendarReminderFormScreen(
              reminder: reminder,
              reminderId: entry.id,
              readOnly: true,
            ),
          ),
        );
      case UpcomingReminderType.bead:
        final item = entry.bead ??
            ref
                .read(itemsNotifierProvider)
                .where((i) => i.id == entry.id)
                .firstOrNull;
        if (item == null) return;
        lockPortraitOnPhones();
        try {
          provider.Provider.of<PrayerAppController>(context, listen: false).setTab(4);
        } catch (_) {}
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ItemFormScreen(
              itemToEdit: item,
              readOnly: true,
            ),
          ),
        );
      case UpcomingReminderType.group:
        final group = entry.group ??
            ref
                .read(groupsNotifierProvider)
                .where((g) => g.id == entry.id)
                .firstOrNull;
        if (group == null) return;
        lockPortraitOnPhones();
        try {
          provider.Provider.of<PrayerAppController>(context, listen: false).setTab(4);
        } catch (_) {}
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GroupFormScreen(
              groupToEdit: group,
              readOnly: true,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              onTap: () => _onTap(context, ref, entry),
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
