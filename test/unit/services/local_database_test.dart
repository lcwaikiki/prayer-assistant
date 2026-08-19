import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';
import 'package:prayer_assistant/src/services/local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;

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

  group('migrations', () {
    Future<Database> openLegacy(
      int version, {
      required void Function(Database db) createSchema,
      void Function(Database db, int old, int fresh)? upgrade,
    }) async {
      final dbPath = path.join(
        await databaseFactoryFfi.getDatabasesPath(),
        'prayer_assistant.db',
      );
      return databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: version,
          onCreate: (db, _) async => createSchema(db),
          onUpgrade: upgrade == null
              ? null
              : (db, old, fresh) async => upgrade(db, old, fresh),
        ),
      );
    }

    test('upgrade from v3 without anchor_date adds the column', () async {
      final legacy = await openLegacy(3, createSchema: (db) async {
        await db.execute('CREATE TABLE prayer_times (id INTEGER PRIMARY KEY)');
        await db.execute('CREATE TABLE app_settings (key TEXT PRIMARY KEY)');
        await db.execute('''
          CREATE TABLE calendar_reminders (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            notes TEXT NOT NULL,
            anchor_at TEXT NOT NULL,
            recurrence TEXT NOT NULL,
            enabled INTEGER NOT NULL
          )
        ''');
      });
      await legacy.close();

      await database.instance;

      final db = await database.instance;
      final columns = await db.rawQuery(
        'PRAGMA table_info(calendar_reminders)',
      );
      expect(columns.map((c) => c['name']), contains('anchor_date'));
    });

    test('upgrade from v3 with anchor_date already present succeeds', () async {
      final legacy = await openLegacy(3, createSchema: (db) async {
        await db.execute('CREATE TABLE prayer_times (id INTEGER PRIMARY KEY)');
        await db.execute('CREATE TABLE app_settings (key TEXT PRIMARY KEY)');
        await db.execute('''
          CREATE TABLE calendar_reminders (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            anchor_at TEXT NOT NULL,
            recurrence TEXT NOT NULL,
            enabled INTEGER NOT NULL,
            anchor_date TEXT
          )
        ''');
      });
      await legacy.close();

      await database.instance;
      final loaded = await database.loadCalendarReminders();

      expect(loaded, isEmpty);
    });

    test('repairs tables that predate the anchor and basis columns and '
        'keeps saving reminders', () async {
      // Tables created by the very first calendar-reminders build only had
      // id/title/notes/anchor_at/recurrence/yearly_basis/enabled; later
      // migrations never ALTERed in monthly_basis, anchor,
      // anchor_prayer_name and anchor_offset_minutes, so saving reminders on
      // such a table used to throw "no such column" and reminders never
      // survived a restart.
      final legacy = await openLegacy(5, createSchema: (db) async {
        await db.execute('CREATE TABLE prayer_times (id INTEGER PRIMARY KEY)');
        await db.execute('CREATE TABLE app_settings (key TEXT PRIMARY KEY)');
        await db.execute('''
          CREATE TABLE calendar_reminders (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            notes TEXT NOT NULL,
            anchor_at TEXT NOT NULL,
            recurrence TEXT NOT NULL,
            yearly_basis TEXT NOT NULL,
            enabled INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          INSERT INTO calendar_reminders
            (id, title, notes, anchor_at, recurrence, yearly_basis, enabled)
          VALUES ('r1', 'Eid', '', '2026-08-17T12:00:00.000', 'weekly',
                  'gregorian', 1)
        ''');
      });
      await legacy.close();

      final loaded = await database.loadCalendarReminders();
      expect(loaded, hasLength(1));
      expect(loaded.single.title, 'Eid');

      final reminder = CalendarReminder(
        id: 'r2',
        title: 'Team',
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        recurrence: ReminderRecurrence.weekly,
        weekdays: [1, 3, 5],
      );
      await database.saveCalendarReminder(reminder);

      final reloaded = await database.loadCalendarReminders();
      expect(reloaded, hasLength(2));
      expect(
        reloaded
            .firstWhere((r) => r.id == 'r2')
            .weekdays,
        [1, 3, 5],
      );
    });

    test('repairs a broken reminders table even when the version is already '
        'current', () async {
      // A device that already ran a current-version build keeps its version
      // number, so no migration fires; the open-time repair must heal the
      // table instead.
      final legacy = await openLegacy(7, createSchema: (db) async {
        await db.execute('CREATE TABLE prayer_times (id INTEGER PRIMARY KEY)');
        await db.execute('CREATE TABLE app_settings (key TEXT PRIMARY KEY)');
        await db.execute('''
          CREATE TABLE calendar_reminders (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            notes TEXT NOT NULL,
            anchor_at TEXT NOT NULL,
            recurrence TEXT NOT NULL,
            yearly_basis TEXT NOT NULL,
            enabled INTEGER NOT NULL
          )
        ''');
      });
      await legacy.close();

      final reminder = CalendarReminder(
        id: 'r2',
        title: 'Team',
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        recurrence: ReminderRecurrence.monthly,
        dayOfMonth: 15,
      );
      await database.saveCalendarReminder(reminder);

      final reloaded = await database.loadCalendarReminders();
      expect(reloaded, hasLength(1));
      expect(reloaded.single.dayOfMonth, 15);
    });

    test('repairs the legacy misspelled table and keeps its data', () async {
      final legacy = await openLegacy(4, createSchema: (db) async {
        await db.execute('CREATE TABLE prayer_times (id INTEGER PRIMARY KEY)');
        await db.execute('CREATE TABLE app_settings (key TEXT PRIMARY KEY)');
        await db.execute('''
          CREATE TABLE calender_reminders (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            notes TEXT NOT NULL,
            anchor_at TEXT NOT NULL,
            recurrence TEXT NOT NULL,
            enabled INTEGER NOT NULL,
            anchor_date TEXT
          )
        ''');
        await db.execute('''
          INSERT INTO calender_reminders
            (id, title, notes, anchor_at, recurrence, enabled)
          VALUES ('r1', 'Eid', '', '2026-08-17T12:00:00.000', 'yearly', 1)
        ''');
      });
      await legacy.close();

      final loaded = await database.loadCalendarReminders();

      expect(loaded, hasLength(1));
      expect(loaded.single.title, 'Eid');
    });

    test('upgrade from v5 keeps reminders and adds the recurrence-day '
        'columns', () async {
      final legacy = await openLegacy(5, createSchema: (db) async {
        await db.execute('CREATE TABLE prayer_times (id INTEGER PRIMARY KEY)');
        await db.execute('CREATE TABLE app_settings (key TEXT PRIMARY KEY)');
        await db.execute('''
          CREATE TABLE calendar_reminders (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            notes TEXT NOT NULL,
            anchor_at TEXT NOT NULL,
            recurrence TEXT NOT NULL,
            monthly_basis TEXT NOT NULL DEFAULT 'gregorian',
            yearly_basis TEXT NOT NULL,
            anchor TEXT NOT NULL DEFAULT 'clockTime',
            anchor_prayer_name TEXT,
            anchor_offset_minutes INTEGER NOT NULL DEFAULT 0,
            anchor_date TEXT,
            enabled INTEGER NOT NULL,
            repeat_count INTEGER
          )
        ''');
        await db.execute('''
          INSERT INTO calendar_reminders
            (id, title, notes, anchor_at, recurrence, monthly_basis,
             yearly_basis, anchor, anchor_offset_minutes, enabled, repeat_count)
          VALUES ('r1', 'Eid', '', '2026-08-17T12:00:00.000', 'weekly',
                  'gregorian', 'gregorian', 'clockTime', 0, 1, 3)
        ''');
      });
      await legacy.close();

      final loaded = await database.loadCalendarReminders();
      expect(loaded, hasLength(1));
      expect(loaded.single.title, 'Eid');
      expect(loaded.single.repeatCount, 3);
      expect(loaded.single.weekdays, isEmpty);
      expect(loaded.single.dayOfMonth, isNull);
      expect(loaded.single.yearlyDate, isNull);

      // A v6 reminder with recurrence-day fields must round-trip after the
      // upgrade (would throw "no such column" otherwise).
      final upgraded = CalendarReminder(
        id: 'r2',
        title: 'Team',
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        recurrence: ReminderRecurrence.weekly,
        weekdays: [1, 3, 5],
      );
      await database.saveCalendarReminder(upgraded);

      final reloaded = await database.loadCalendarReminders();
      expect(reloaded.map((r) => r.id), ['r1', 'r2']);
      expect(
        reloaded
            .firstWhere((r) => r.id == 'r2')
            .weekdays,
        [1, 3, 5],
      );
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