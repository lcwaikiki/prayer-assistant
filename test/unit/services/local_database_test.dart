import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';
import 'package:prayer_assistant/src/services/local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late LocalDatabase database;

  setUp(() async {
    final databasesPath = await databaseFactoryFfi.getDatabasesPath();
    await databaseFactoryFfi.deleteDatabase(
      '$databasesPath/prayer_assistant.db',
    );
    database = LocalDatabase();
  });

  tearDown(() async {
    await database.closeForTest();
  });

  group('selected location', () {
    test('round-trips a saved location', () async {
      final location = SelectedLocation(
        countryId: 'tr',
        countryName: 'Turkiye',
        stateId: '34',
        stateName: 'Istanbul',
        districtId: '541',
        districtName: 'Uskudar',
      );

      await database.saveSelectedLocation(location);

      final loaded = await database.loadSelectedLocation();

      expect(loaded!.fullName, 'Uskudar, Istanbul, Turkiye');
    });

    test('returns null when nothing was saved', () async {
      expect(await database.loadSelectedLocation(), isNull);
    });
  });

  group('reminder settings', () {
    test('round-trips a settings map', () async {
      final settings = {
        'Imsak': ReminderSetting(
          minutesBefore: 15,
          customMinutesBefore: 20,
          minutesAfter: 30,
          customMinutesAfter: 25,
          notifyOnTime: true,
          notifyBefore: true,
          notifyAfter: true,
          vibrationEnabled: false,
          soundEnabled: true,
        ),
        'Yatsi': ReminderSetting.defaults(),
      };

      await database.saveReminderSettings(settings);

      final loaded = await database.loadReminderSettings();

      expect(loaded['Imsak']!.notifyBefore, isTrue);
      expect(loaded['Imsak']!.notifyAfter, isTrue);
      expect(loaded['Imsak']!.vibrationEnabled, isFalse);
      expect(loaded['Yatsi']!.notifyBefore, isFalse);
    });

    test('returns empty map when nothing was saved', () async {
      expect(await database.loadReminderSettings(), isEmpty);
    });

    test('returns empty map for corrupted JSON', () async {
      final db = await database.instance;
      await db.insert('app_settings', {
        'setting_key': 'reminder_settings',
        'setting_value': 'not-json',
      });

      expect(await database.loadReminderSettings(), isEmpty);
    });
  });

  group('string and boolean preferences', () {
    test('app bar placement round-trips', () async {
      await database.saveAppBarRemainingPlacement('trailing');
      expect(await database.loadAppBarRemainingPlacement(), 'trailing');
    });

    test('widget text size round-trips', () async {
      await database.saveWidgetTextSize('large');
      expect(await database.loadWidgetTextSize(), 'large');
    });

    test('boolean preferences round-trip', () async {
      await database.saveStatusBarRemainingEnabled(true);
      expect(await database.loadStatusBarRemainingEnabled(), isTrue);

      await database.saveRemindersSilenced(true);
      expect(await database.loadRemindersSilenced(), isTrue);

      await database.saveReminderVibrationEnabled(false);
      expect(await database.loadReminderVibrationEnabled(), isFalse);

      await database.saveReminderSoundEnabled(false);
      expect(await database.loadReminderSoundEnabled(), isFalse);

      await database.saveShowSecondaryCalendarDate(false);
      expect(await database.loadShowSecondaryCalendarDate(), isFalse);
    });

    test('theme and locale preferences round-trip', () async {
      await database.saveThemePreference('dark');
      expect(await database.loadThemePreference(), 'dark');

      await database.saveLocalePreference('ru');
      expect(await database.loadLocalePreference(), 'ru');

      await database.saveCalendarPrimaryDisplay('gregorian');
      expect(await database.loadCalendarPrimaryDisplay(), 'gregorian');
    });

    test('loaders return null when unset', () async {
      expect(await database.loadAppBarRemainingPlacement(), isNull);
      expect(await database.loadStatusBarRemainingEnabled(), isNull);
      expect(await database.loadThemePreference(), isNull);
      expect(await database.loadLocalePreference(), isNull);
      expect(await database.loadCalendarPrimaryDisplay(), isNull);
    });
  });

  group('prayer times', () {
    test('upsert + getDay round-trips a single day', () async {
      final day = _day(DateTime(2026, 8, 17));

      await database.upsertPrayerDays('541', [day]);

      final loaded = await database.getDay(
        districtId: '541',
        date: DateTime(2026, 8, 17),
      );

      expect(loaded!.imsak, day.imsak);
      expect(loaded.hijriDate, day.hijriDate);
    });

    test('getDay returns null when missing', () async {
      expect(
        await database.getDay(
          districtId: '541',
          date: DateTime(2026, 8, 17),
        ),
        isNull,
      );
    });

    test('upserting the same date replaces the row', () async {
      await database.upsertPrayerDays('541', [_day(DateTime(2026, 8, 17))]);
      await database.upsertPrayerDays(
        '541',
        [_day(DateTime(2026, 8, 17), imsak: '06:00')],
      );

      final loaded = await database.getDay(
        districtId: '541',
        date: DateTime(2026, 8, 17),
      );

      expect(loaded!.imsak, '06:00');
    });

    test('getRange returns only days inside the bounds, sorted', () async {
      await database.upsertPrayerDays('541', [
        _day(DateTime(2026, 8, 17)),
        _day(DateTime(2026, 8, 10)),
        _day(DateTime(2026, 9, 1)),
      ]);

      final range = await database.getRange(
        districtId: '541',
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 31),
      );

      expect(range.map((d) => d.date.day), [10, 17]);
    });

    test('getRange is scoped per district', () async {
      await database.upsertPrayerDays('541', [_day(DateTime(2026, 8, 17))]);

      final other = await database.getRange(
        districtId: '999',
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 12, 31),
      );

      expect(other, isEmpty);
    });

    test('hasSufficientYearData is false for a nearly empty year', () async {
      await database.upsertPrayerDays('541', [_day(DateTime(2026, 8, 17))]);

      expect(
        await database.hasSufficientYearData(districtId: '541', year: 2026),
        isFalse,
      );
    });

    test('hasSufficientYearData is true for a full year with hijri dates',
        () async {
      final days = List.generate(
        365,
        (i) => _day(
          DateTime(2026, 1, 1).add(Duration(days: i)),
          hijri: 'day $i',
        ),
      );
      await database.upsertPrayerDays('541', days);

      expect(
        await database.hasSufficientYearData(districtId: '541', year: 2026),
        isTrue,
      );
    });

    test('hasSufficientYearData ignores rows without hijri dates', () async {
      final days = List.generate(
        365,
        (i) => _day(
          DateTime(2026, 1, 1).add(Duration(days: i)),
          hijri: '',
        ),
      );
      await database.upsertPrayerDays('541', days);

      expect(
        await database.hasSufficientYearData(districtId: '541', year: 2026),
        isFalse,
      );
    });

    test('upserting an empty list is a no-op', () async {
      await database.upsertPrayerDays('541', const []);

      expect(
        await database.getDay(
          districtId: '541',
          date: DateTime(2026, 8, 17),
        ),
        isNull,
      );
    });
  });

  group('calendar reminders', () {
    test('save/load/delete round-trip', () async {
      final reminder = CalendarReminder(
        id: 'r1',
        title: 'Eid',
        notes: 'notes',
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        recurrence: ReminderRecurrence.yearly,
        yearlyBasis: CalendarBasis.hijri,
        anchor: CalendarReminderAnchor.prayerTime,
        anchorPrayerName: 'Aksam',
        anchorOffsetMinutes: -15,
        anchorDate: DateTime(2026, 8, 17),
        enabled: false,
      );

      await database.saveCalendarReminder(reminder);

      final loaded = await database.loadCalendarReminders();
      expect(loaded, hasLength(1));
      expect(loaded.single.title, 'Eid');
      expect(loaded.single.anchor, CalendarReminderAnchor.prayerTime);
      expect(loaded.single.yearlyBasis, CalendarBasis.hijri);
      expect(loaded.single.anchorOffsetMinutes, -15);
      expect(loaded.single.enabled, isFalse);

      await database.deleteCalendarReminder('r1');
      expect(await database.loadCalendarReminders(), isEmpty);
    });

    test('loadCalendarReminders orders by anchor time', () async {
      await database.saveCalendarReminder(
        CalendarReminder(
          id: 'later',
          title: 'Later',
          anchorAt: DateTime(2026, 12, 1),
        ),
      );
      await database.saveCalendarReminder(
        CalendarReminder(
          id: 'earlier',
          title: 'Earlier',
          anchorAt: DateTime(2026, 1, 1),
        ),
      );

      final loaded = await database.loadCalendarReminders();

      expect(loaded.map((r) => r.id), ['earlier', 'later']);
    });
  });
}

PrayerDay _day(DateTime date, {String imsak = '05:10', String hijri = 'x'}) {
  return PrayerDay(
    date: date,
    hijriDate: hijri,
    imsak: imsak,
    gunes: '06:42',
    ogle: '12:35',
    ikindi: '16:10',
    aksam: '18:20',
    yatsi: '19:45',
  );
}

extension on LocalDatabase {
  Future<void> closeForTest() async {
    final db = await instance;
    await db.close();
  }
}