import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/kaza/models/kaza_tracker.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';
import 'package:prayer_assistant/src/services/backup_export_service.dart';
import 'package:prayer_assistant/src/tesbihat/models/daily_item_stat.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/item_group.dart';

void main() {
  group('BackupExportService', () {
    const service = BackupExportService();

    test('generateJsonBackup and parseAndValidateBackup roundtrip works correctly', () {
      const kaza = KazaTracker(
        fajrTarget: 365,
        fajrCompleted: 50,
        dhuhrTarget: 365,
        dhuhrCompleted: 40,
        dailyPace: 2,
      );

      final completions = <String, List<String>>{
        '2026-08-22': ['Imsak', 'Ogle'],
      };

      final reminders = <CalendarReminder>[
        CalendarReminder(
          id: 'rem-1',
          title: 'Surah Al-Kahf',
          anchorAt: DateTime(2026, 8, 22, 10, 0),
        ),
      ];

      final items = <Item>[
        const Item(
          id: 'bead-1',
          title: 'SubhanAllah',
          count: 33,
          check: 11,
          setCount: 0,
          vibrationIntensity: 50,
        ),
      ];

      final groups = <ItemGroup>[
        const ItemGroup(
          id: 'grp-1',
          title: 'Morning Azkar',
        ),
      ];

      final stats = <DailyItemStat>[
        const DailyItemStat(
          itemId: 'bead-1',
          dateKey: '2026-08-22',
          count: 33,
        ),
      ];

      final prefs = <String, dynamic>{'themePreference': 'dark'};

      final jsonStr = service.generateJsonBackup(
        kazaTracker: kaza,
        prayerCompletions: completions,
        calendarReminders: reminders,
        tesbihItems: items,
        tesbihGroups: groups,
        tesbihStats: stats,
        preferences: prefs,
      );

      expect(jsonStr, contains('PrayerAssistant'));
      expect(jsonStr, contains('SubhanAllah'));

      final restored = service.parseAndValidateBackup(jsonStr);

      final restoredKaza = restored['kazaTracker'] as KazaTracker;
      expect(restoredKaza.fajrTarget, 365);
      expect(restoredKaza.fajrCompleted, 50);

      final restoredCompletions = restored['prayerCompletions'] as Map<String, List<String>>;
      expect(restoredCompletions['2026-08-22'], contains('Imsak'));

      final restoredReminders = restored['calendarReminders'] as List<CalendarReminder>;
      expect(restoredReminders.first.title, 'Surah Al-Kahf');

      final restoredItems = restored['tesbihItems'] as List<Item>;
      expect(restoredItems.first.title, 'SubhanAllah');
    });



    test('generateIslamicHolidaysIcs generates valid RFC 5545 format', () {
      final ashuraDate = HijriCalendar().hijriToGregorian(1448, 1, 10);
      final days = <PrayerDay>[
        PrayerDay(
          date: ashuraDate,
          hijriDate: '10 Muharram 1448',
          imsak: '04:30',
          gunes: '06:00',
          ogle: '13:00',
          ikindi: '16:45',
          aksam: '19:30',
          yatsi: '21:00',
        ),
      ];

      final ics = service.generateIslamicHolidaysIcs(
        days: days,
        holidayLabel: (key) => 'Ashura',
      );

      expect(ics, contains('BEGIN:VCALENDAR'));
      expect(ics, contains('END:VCALENDAR'));
      expect(ics, contains('Ashura'));
    });
  });
}
