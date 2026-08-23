import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../calendar/models/calendar_reminder.dart';
import '../kaza/models/kaza_tracker.dart';
import '../models/fasting_models.dart';
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
  static const _prayerCompletionsKey = 'prayer_completions';
  static const _kazaTrackerKey = 'kaza_tracker_data';
  static const _fastingLogsKey = 'fasting_logs';

  Database? _db;


  Future<Database> get instance async {
    if (_db != null) {
      return _db!;
    }
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, _dbName);
    _db = await openDatabase(
      dbPath,
      version: 7,
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
        await _ensureCalendarReminderColumns(db);
      },
      onOpen: (db) async {
        await _renameLegacyMisspelledRemindersTable(db);
        await _ensureCalendarReminderColumns(db);
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

  /// Ensures every column the app writes exists on the reminders table.
  /// Tables created by the earliest reminder builds only had
  /// id/title/notes/anchor_at/recurrence/yearly_basis/enabled; no migration
  /// ever ALTERed in the anchor/basis columns, so saving used to throw
  /// "no such column" and reminders silently vanished on restart. All checks
  /// are PRAGMA-based and no-ops on complete tables; runs on every upgrade
  /// and on every open so databases already at the current version are
  /// repaired too.
  static Future<void> _ensureCalendarReminderColumns(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(calendar_reminders)');
    final names = columns.map((row) => row['name']).toSet();
    if (!names.contains('monthly_basis')) {
      await db.execute(
        "ALTER TABLE calendar_reminders ADD COLUMN monthly_basis TEXT NOT NULL DEFAULT 'gregorian'",
      );
    }
    if (!names.contains('yearly_basis')) {
      await db.execute(
        "ALTER TABLE calendar_reminders ADD COLUMN yearly_basis TEXT NOT NULL DEFAULT 'gregorian'",
      );
    }
    if (!names.contains('anchor')) {
      await db.execute(
        "ALTER TABLE calendar_reminders ADD COLUMN anchor TEXT NOT NULL DEFAULT 'clockTime'",
      );
    }
    if (!names.contains('anchor_prayer_name')) {
      await db.execute(
        'ALTER TABLE calendar_reminders ADD COLUMN anchor_prayer_name TEXT',
      );
    }
    if (!names.contains('anchor_offset_minutes')) {
      await db.execute(
        'ALTER TABLE calendar_reminders ADD COLUMN anchor_offset_minutes INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!names.contains('anchor_date')) {
      await db.execute(
        'ALTER TABLE calendar_reminders ADD COLUMN anchor_date TEXT',
      );
    }
    if (!names.contains('repeat_count')) {
      await db.execute(
        'ALTER TABLE calendar_reminders ADD COLUMN repeat_count INTEGER',
      );
    }
    if (!names.contains('weekdays')) {
      await db.execute(
        "ALTER TABLE calendar_reminders ADD COLUMN weekdays TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!names.contains('day_of_month')) {
      await db.execute(
        'ALTER TABLE calendar_reminders ADD COLUMN day_of_month INTEGER',
      );
    }
    if (!names.contains('yearly_date')) {
      await db.execute(
        'ALTER TABLE calendar_reminders ADD COLUMN yearly_date TEXT',
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
      enabled INTEGER NOT NULL,
      repeat_count INTEGER,
      weekdays TEXT NOT NULL DEFAULT '',
      day_of_month INTEGER,
      yearly_date TEXT
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

  static const _widgetMmssThresholdKey = 'widget_mmss_threshold_minutes';

  Future<void> saveWidgetMmssThreshold(int minutes) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _widgetMmssThresholdKey,
      'setting_value': minutes.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// The minutes below which widgets count down in MM:SS (0-60, default 60).
  Future<int> loadWidgetMmssThreshold() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_widgetMmssThresholdKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return 60;
    }
    final raw = rows.first['setting_value'] as String?;
    return int.tryParse(raw ?? '')?.clamp(0, 60) ?? 60;
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

  Future<Map<String, List<String>>> loadPrayerCompletions() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_prayerCompletionsKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return <String, List<String>>{};
    }
    try {
      final raw =
          jsonDecode(rows.first['setting_value'] as String)
              as Map<String, dynamic>;
      return raw.map(
        (key, value) =>
            MapEntry(key, List<String>.from(value as List)),
      );
    } catch (_) {
      return <String, List<String>>{};
    }
  }

  Future<void> savePrayerCompletions(
    Map<String, List<String>> completions,
  ) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _prayerCompletionsKey,
      'setting_value': jsonEncode(completions),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<KazaTracker> loadKazaTracker() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_kazaTrackerKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return const KazaTracker();
    }
    try {
      final jsonStr = rows.first['setting_value'] as String;
      return KazaTracker.fromJson(jsonStr);
    } catch (_) {
      return const KazaTracker();
    }
  }

  Future<void> saveKazaTracker(KazaTracker tracker) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _kazaTrackerKey,
      'setting_value': tracker.toJson(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, FastingLog>> loadFastingLogs() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_fastingLogsKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return <String, FastingLog>{};
    }
    try {
      final raw =
          jsonDecode(rows.first['setting_value'] as String)
              as Map<String, dynamic>;
      return raw.map(
        (key, value) => MapEntry(
          key,
          FastingLog.fromMap(value as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      return <String, FastingLog>{};
    }
  }

  Future<void> saveFastingLogs(Map<String, FastingLog> logs) async {
    final db = await instance;
    final raw = logs.map((key, value) => MapEntry(key, value.toMap()));
    await db.insert('app_settings', {
      'setting_key': _fastingLogsKey,
      'setting_value': jsonEncode(raw),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  String _toDateKey(DateTime date) {
    final safe = DateTime(date.year, date.month, date.day);
    return '${safe.year.toString().padLeft(4, '0')}-'
        '${safe.month.toString().padLeft(2, '0')}-'
        '${safe.day.toString().padLeft(2, '0')}';
  }
}

