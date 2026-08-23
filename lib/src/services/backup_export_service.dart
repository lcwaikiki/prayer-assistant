import 'dart:convert';
import 'package:intl/intl.dart';

import '../calendar/models/calendar_reminder.dart';
import '../calendar/hijri_utils.dart';
import '../kaza/models/kaza_tracker.dart';
import '../models/fasting_models.dart';
import '../models/prayer_models.dart';
import '../tesbihat/models/daily_item_stat.dart';
import '../tesbihat/models/item.dart';
import '../tesbihat/models/item_group.dart';

class BackupExportService {
  const BackupExportService();

  /// Generates a comprehensive JSON backup string containing all app data.
  String generateJsonBackup({
    required KazaTracker kazaTracker,
    required Map<String, List<String>> prayerCompletions,
    required List<CalendarReminder> calendarReminders,
    required List<Item> tesbihItems,
    required List<ItemGroup> tesbihGroups,
    required List<DailyItemStat> tesbihStats,
    required Map<String, dynamic> preferences,
    Map<String, FastingLog> fastingLogs = const {},
  }) {
    final data = <String, dynamic>{
      'version': 1,
      'app': 'PrayerAssistant',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'kazaTracker': kazaTracker.toMap(),
      'prayerCompletions': prayerCompletions,
      'calendarReminders': calendarReminders.map((r) => r.toMap()).toList(),
      'tesbihItems': tesbihItems.map((i) => i.toMap()).toList(),
      'tesbihGroups': tesbihGroups.map((g) => g.toMap()).toList(),
      'tesbihStats': tesbihStats.map((s) => s.toMap()).toList(),
      'preferences': preferences,
      'fastingLogs': fastingLogs.map((k, v) => MapEntry(k, v.toMap())),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }


  /// Parses and validates a JSON backup payload. Returns a map with parsed objects.
  Map<String, dynamic> parseAndValidateBackup(String jsonString) {
    final Map<String, dynamic> raw;
    try {
      raw = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Invalid JSON format');
    }

    if (raw['app'] != 'PrayerAssistant' && !raw.containsKey('kazaTracker')) {
      throw const FormatException('Unrecognized backup format');
    }

    final kazaTrackerMap = raw['kazaTracker'] as Map<String, dynamic>?;
    final kazaTracker = kazaTrackerMap != null
        ? KazaTracker.fromMap(kazaTrackerMap)
        : const KazaTracker();

    final completionsRaw = raw['prayerCompletions'] as Map<String, dynamic>?;
    final prayerCompletions = <String, List<String>>{};
    if (completionsRaw != null) {
      for (final entry in completionsRaw.entries) {
        final list = (entry.value as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[];
        prayerCompletions[entry.key] = list;
      }
    }

    final remindersRaw = raw['calendarReminders'] as List<dynamic>?;
    final calendarReminders = remindersRaw != null
        ? remindersRaw
            .whereType<Map<String, dynamic>>()
            .map((m) => CalendarReminder.fromMap(m))
            .toList()
        : const <CalendarReminder>[];

    final tesbihItemsRaw = raw['tesbihItems'] as List<dynamic>?;
    final tesbihItems = tesbihItemsRaw != null
        ? tesbihItemsRaw
            .whereType<Map<String, dynamic>>()
            .map((m) => Item.fromMap(m))
            .toList()
        : const <Item>[];

    final tesbihGroupsRaw = raw['tesbihGroups'] as List<dynamic>?;
    final tesbihGroups = tesbihGroupsRaw != null
        ? tesbihGroupsRaw
            .whereType<Map<String, dynamic>>()
            .map((m) => ItemGroup.fromMap(m))
            .toList()
        : const <ItemGroup>[];

    final tesbihStatsRaw = raw['tesbihStats'] as List<dynamic>?;
    final tesbihStats = tesbihStatsRaw != null
        ? tesbihStatsRaw
            .whereType<Map<String, dynamic>>()
            .map(
              (m) => DailyItemStat(
                itemId: (m['itemId'] ?? '').toString(),
                dateKey: (m['dateKey'] ?? '').toString(),
                count: (m['count'] as num?)?.toInt() ?? 0,
              ),
            )
            .toList()
        : const <DailyItemStat>[];

    final preferences =
        (raw['preferences'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final fastingLogsRaw = raw['fastingLogs'] as Map<String, dynamic>?;
    final fastingLogs = <String, FastingLog>{};
    if (fastingLogsRaw != null) {
      for (final entry in fastingLogsRaw.entries) {
        if (entry.value is Map<String, dynamic>) {
          fastingLogs[entry.key] =
              FastingLog.fromMap(entry.value as Map<String, dynamic>);
        }
      }
    }

    return {
      'kazaTracker': kazaTracker,
      'prayerCompletions': prayerCompletions,
      'calendarReminders': calendarReminders,
      'tesbihItems': tesbihItems,
      'tesbihGroups': tesbihGroups,
      'tesbihStats': tesbihStats,
      'preferences': preferences,
      'fastingLogs': fastingLogs,
    };
  }





  /// Formats 10 Islamic holidays for the active calendar year into RFC 5545 iCalendar (.ics) format.
  String generateIslamicHolidaysIcs({
    required List<PrayerDay> days,
    required String Function(String key) holidayLabel,
  }) {
    final buf = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//Prayer Assistant//Islamic Holidays//EN')
      ..writeln('CALSCALE:GREGORIAN')
      ..writeln('METHOD:PUBLISH')
      ..writeln('X-WR-CALNAME:Islamic Holidays');

    final nowIso = _formatIcsDateTime(DateTime.now().toUtc());

    for (final day in days) {
      final holiday = islamicHolidayForDate(day.date, holidayLabel);
      if (holiday == null) continue;

      final dateStr = DateFormat('yyyyMMdd').format(day.date);
      final nextDateStr = DateFormat('yyyyMMdd').format(day.date.add(const Duration(days: 1)));

      buf
        ..writeln('BEGIN:VEVENT')
        ..writeln('UID:holiday-${dateStr}-${holiday.hashCode}@prayerassistant.app')
        ..writeln('DTSTAMP:$nowIso')
        ..writeln('DTSTART;VALUE=DATE:$dateStr')
        ..writeln('DTEND;VALUE=DATE:$nextDateStr')
        ..writeln('SUMMARY:$holiday')
        ..writeln('DESCRIPTION:Islamic Holiday: $holiday')
        ..writeln('STATUS:CONFIRMED')
        ..writeln('END:VEVENT');
    }

    buf.writeln('END:VCALENDAR');
    return buf.toString();
  }

  String _formatIcsDateTime(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$year$month${day}T$hour$minute${second}Z';
  }
}
