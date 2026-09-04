import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../calendar/models/calendar_reminder.dart';
import '../../calendar/screens/hijri_calendar_screen.dart';
import '../../l10n/l10n.dart';

typedef UpcomingReminder = ({CalendarReminder reminder, DateTime next});

class UpcomingRemindersCard extends StatelessWidget {
  const UpcomingRemindersCard({super.key, required this.entries});

  final List<UpcomingReminder> entries;

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
