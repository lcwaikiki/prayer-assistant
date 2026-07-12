import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/prayer_models.dart';

class LocalDatabase {
  static const _dbName = 'prayer_assistant.db';
  static const _selectedLocationKey = 'selected_location';
  static const _reminderSettingsKey = 'reminder_settings';
  static const _appBarRemainingPlacementKey = 'app_bar_remaining_placement';
  static const _statusBarRemainingEnabledKey = 'status_bar_remaining_enabled';
  static const _statusBarAutoRestoreKey = 'status_bar_auto_restore';
  Database? _db;

  Future<Database> get instance async {
    if (_db != null) {
      return _db!;
    }
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, _dbName);
    _db = await openDatabase(
      dbPath,
      version: 2,
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE prayer_times ADD COLUMN hijri_date TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );
    return _db!;
  }

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

  Future<void> saveStatusBarAutoRestore(bool enabled) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _statusBarAutoRestoreKey,
      'setting_value': enabled ? 'true' : 'false',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool?> loadStatusBarAutoRestore() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_statusBarAutoRestoreKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return (rows.first['setting_value'] as String?) == 'true';
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
