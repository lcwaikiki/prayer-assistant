import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/prayer_models.dart';

class LocalDatabase {
  static const _dbName = 'prayer_assistant.db';
  static const _selectedLocationKey = 'selected_location';
  static const _reminderSettingsKey = 'reminder_settings';
  Database? _db;

  Future<Database> get instance async {
    if (_db != null) {
      return _db!;
    }
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, _dbName);
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE prayer_times (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            district_id TEXT NOT NULL,
            date TEXT NOT NULL,
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

  Future<void> saveReminderSettings(Map<String, bool> settings) async {
    final db = await instance;
    await db.insert('app_settings', {
      'setting_key': _reminderSettingsKey,
      'setting_value': jsonEncode(settings),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, bool>> loadReminderSettings() async {
    final db = await instance;
    final rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [_reminderSettingsKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return <String, bool>{};
    }
    try {
      final raw =
          jsonDecode(rows.first['setting_value'] as String)
              as Map<String, dynamic>;
      return raw.map((key, value) => MapEntry(key, value == true));
    } catch (_) {
      return <String, bool>{};
    }
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
        SELECT COUNT(1) AS count
        FROM prayer_times
        WHERE district_id = ?
          AND date >= ?
          AND date <= ?
      ''',
      [districtId, '$year-01-01', '$year-12-31'],
    );
    final count = (rows.first['count'] as int?) ?? 0;
    return count >= 360;
  }

  String _toDateKey(DateTime date) {
    final safe = DateTime(date.year, date.month, date.day);
    return '${safe.year.toString().padLeft(4, '0')}-'
        '${safe.month.toString().padLeft(2, '0')}-'
        '${safe.day.toString().padLeft(2, '0')}';
  }
}
