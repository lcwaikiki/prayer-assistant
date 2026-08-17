import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../calendar/models/calendar_reminder.dart';
import '../models/prayer_models.dart';

class LocalDatabase {
  static const _dbName = 'prayer_assistant.db';
  static const _selectedLocationKey = 'selected_location';
  static const _reminderSettingsKey = 'reminder_settings';
  static const _appBarRemainingPlacementKey = 'app_bar_remaining_placement';
  static const _widgetTextSizeKey = 'widget_text_size';
  static const _statusBarRemainingEnabledKey = 'status_bar_remaining_enabled';
  static const _remindersSilencedKey = 'reminders_silenced';
  static const _reminderVibrationEnabledKey = 'reminder_vibration_enabled';
  static const _reminderSoundEnabledKey = 'reminder_sound_enabled';
  static const _themePreferenceKey = 'theme_preference';
  static const _localePreferenceKey = 'locale_preference';
  static const _calendarPrimaryDisplayKey = 'calendar_primary_display';
  static const _showSecondaryCalendarDateKey = 'show_secondary_calendar_date';
  Database? _db;

  Future<Database> get instance async {
    if (_db != null) {
      return _db!;
    }
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, _dbName);
    _db = await openDatabase(
      dbPath,
      version: 4,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE prayer_times (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            district_id TEXT NOT NULL,
            date TEXT NOT NULL,
            hijri_date TEXT NOT NULL DEFAULT '',
            imsak TEXT NOT NULL,
            gunes TEXT NOT NULL,
            ogle TEXT NOT NULL,
            ikindi TEXT NOT NULL,
            aksam TEXT NOT NULL,
            yatsi TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            UNIQUE(district_id, date)
          )
        ''');
        await db.execute('''
          CREATE TABLE app_settings (
            setting_key TEXT PRIMARY KEY,
            setting_value TEXT NOT NULL
          )
        ''');
        await db.execute(_createCalendarRemindersTableSql);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _renameLegacyMisspelledRemindersTable(db);
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE prayer_times ADD COLUMN hijri_date TEXT NOT NULL DEFAULT ''",
          );
        }
        if (oldVersion < 3) {
          await _ensureCalendarRemindersTable(db);
        }
        if (oldVersion < 4) {
          await _ensureAnchorDateColumn(db);
        }
      },
      onOpen: (db) async {
        await _renameLegacyMisspelledRemindersTable(db);
      },
    );
    return _db!;
  }

  /// Older dev builds misspelled the reminders table as 'calender_reminders'
  /// (and could fail mid-migration). Rename it to the correct name so the
  /// stored reminders survive; no-op when the correct table already exists.
  static Future<void> _renameLegacyMisspelledRemindersTable(
    Database db,
  ) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final names = tables.map((row) => row['name']).toSet();
    if (names.contains('calender_reminders') &&
        !names.contains('calendar_reminders')) {
      await db.execute(
        'ALTER TABLE calender_reminders RENAME TO calendar_reminders',
      );
    }
  }

  static Future<void> _ensureCalendarRemindersTable(Database db) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'calendar_reminders'",
    );
    if (rows.isEmpty) {
      await db.execute(_createCalendarRemindersTableSql);
    }
  }

  /// Adds the v4 column only when missing; the table may already carry it
  /// (created by v3 SQL that already included the column), which made the
  /// plain ALTER fail with "duplicate column name".
  static Future<void> _ensureAnchorDateColumn(Database db) async {
    final columns = await db.rawQuery(
      'PRAGMA table_info(calendar_reminders)',
    );
    final hasAnchorDate = columns.any((row) => row['name'] == 'anchor_date');
    if (!hasAnchorDate) {
      await db.execute(
        'ALTER TABLE calendar_reminders ADD COLUMN anchor_date TEXT',
      );
    }
  }

  static const _createCalendarRemindersTableSql = '''
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
      enabled INTEGER NOT NULL
    )
  ''';

  Future<void> saveSelectedLocation(SelectedLocation location) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _selectedLocationKey,
      'setting_value': jsonEncode(location.toJson()),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<SelectedLocation?> loadSelectedLocation() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_selectedLocationKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return SelectedLocation.tryParse(rows.first['setting_value'] as String?);
  }

  Future<void> saveReminderSettings(
    Map<String, ReminderSetting> settings,
  ) async {
    final db = await instance;
    final encoded = settings.map((key, value) => MapEntry(key, value.toJson()));
    await db.insert('app_settings', {
      'setting_key': _reminderSettingsKey,
      'setting_value': jsonEncode(encoded),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, ReminderSetting>> loadReminderSettings() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_reminderSettingsKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return <String, ReminderSetting>{};
    }
    try {
      final raw =
          jsonDecode(rows.first['setting_value'] as String)
              as Map<String, dynamic>;
      return raw.map(
        (key, value) => MapEntry(key, ReminderSetting.fromJson(value)),
      );
    } catch (_) {
      return <String, ReminderSetting>{};
    }
  }

  Future<void> saveAppBarRemainingPlacement(String value) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _appBarRemainingPlacementKey,
      'setting_value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> loadAppBarRemainingPlacement() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_appBarRemainingPlacementKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['setting_value'] as String?;
  }

  Future<void> saveWidgetTextSize(String value) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _widgetTextSizeKey,
      'setting_value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> loadWidgetTextSize() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_widgetTextSizeKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['setting_value'] as String?;
  }

  Future<void> saveStatusBarRemainingEnabled(bool enabled) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _statusBarRemainingEnabledKey,
      'setting_value': enabled ? 'true' : 'false',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool?> loadStatusBarRemainingEnabled() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_statusBarRemainingEnabledKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return (rows.first['setting_value'] as String?) == 'true';
  }

  Future<void> saveRemindersSilenced(bool silenced) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _remindersSilencedKey,
      'setting_value': silenced ? 'true' : 'false',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool?> loadRemindersSilenced() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_remindersSilencedKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return (rows.first['setting_value'] as String?) == 'true';
  }

  Future<void> saveReminderVibrationEnabled(bool enabled) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _reminderVibrationEnabledKey,
      'setting_value': enabled ? 'true' : 'false',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool?> loadReminderVibrationEnabled() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_reminderVibrationEnabledKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return (rows.first['setting_value'] as String?) == 'true';
  }

  Future<void> saveReminderSoundEnabled(bool enabled) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _reminderSoundEnabledKey,
      'setting_value': enabled ? 'true' : 'false',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool?> loadReminderSoundEnabled() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_reminderSoundEnabledKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return (rows.first['setting_value'] as String?) == 'true';
  }

  Future<void> saveThemePreference(String value) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _themePreferenceKey,
      'setting_value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> loadThemePreference() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_themePreferenceKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['setting_value'] as String?;
  }

  Future<void> saveLocalePreference(String value) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _localePreferenceKey,
      'setting_value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> loadLocalePreference() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_localePreferenceKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['setting_value'] as String?;
  }

  Future<void> saveCalendarPrimaryDisplay(String value) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _calendarPrimaryDisplayKey,
      'setting_value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> loadCalendarPrimaryDisplay() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_calendarPrimaryDisplayKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['setting_value'] as String?;
  }

  Future<void> saveShowSecondaryCalendarDate(bool enabled) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _showSecondaryCalendarDateKey,
      'setting_value': enabled ? 'true' : 'false',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool?> loadShowSecondaryCalendarDate() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_showSecondaryCalendarDateKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return (rows.first['setting_value'] as String?) == 'true';
  }

  Future<List<CalendarReminder>> loadCalendarReminders() async {
    final db = await instance;
    final rows = await db.query('calendar_reminders', orderBy: 'anchor_at ASC');
    return rows.map(CalendarReminder.fromMap).toList(growable: false);
  }

  Future<void> saveCalendarReminder(CalendarReminder reminder) async {
    final db = await instance;
    await db.insert(
      'calendar_reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCalendarReminder(String id) async {
    final db = await instance;
    await db.delete('calendar_reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> upsertPrayerDays(String districtId, List<PrayerDay> days) async {
    if (days.isEmpty) {
      return;
    }
    final db = await instance;
    final batch = db.batch();
    for (final day in days) {
      batch.insert(
        'prayer_times',
        day.toMap(districtId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<PrayerDay?> getDay({
    required String districtId,
    required DateTime date,
  }) async {
    final db = await instance;
    final key = _toDateKey(date);
    final rows = await db.query(
      'prayer_times',
      where: 'district_id = ? AND date = ?',
      whereArgs: [districtId, key],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return PrayerDay.fromMap(rows.first);
  }

  Future<List<PrayerDay>> getRange({
    required String districtId,
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await instance;
    final rows = await db.query(
      'prayer_times',
      where: 'district_id = ? AND date >= ? AND date <= ?',
      whereArgs: [districtId, _toDateKey(start), _toDateKey(end)],
      orderBy: 'date ASC',
    );
    return rows.map(PrayerDay.fromMap).toList(growable: false);
  }

  Future<bool> hasSufficientYearData({
    required String districtId,
    required int year,
  }) async {
    final db = await instance;
    final rows = await db.rawQuery(
      '''
        SELECT
          COUNT(1) AS count,
          SUM(CASE WHEN hijri_date IS NOT NULL AND hijri_date != '' THEN 1 ELSE 0 END) AS hijri_count
        FROM prayer_times
        WHERE district_id = ?
          AND date >= ?
          AND date <= ?
      ''',
      [districtId, '$year-01-01', '$year-12-31'],
    );
    final count = (rows.first['count'] as int?) ?? 0;
    final hijriCount = (rows.first['hijri_count'] as int?) ?? 0;
    return count >= 360 && hijriCount >= 360;
  }

  String _toDateKey(DateTime date) {
    final safe = DateTime(date.year, date.month, date.day);
    return '${safe.year.toString().padLeft(4, '0')}-'
        '${safe.month.toString().padLeft(2, '0')}-'
        '${safe.day.toString().padLeft(2, '0')}';
  }
}
