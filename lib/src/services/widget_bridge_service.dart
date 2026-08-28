import 'dart:ui';

import 'package:flutter/services.dart';

import '../l10n/prayer_names.dart';
import '../models/prayer_models.dart';
import '../utils/time_utils.dart';

class WidgetBridgeService {
  static const MethodChannel _channel = MethodChannel('prayer_assistant/widget');
  bool _hasHomeListener = false;

  Future<void> updateFromPrayerDays({
    required List<PrayerDay> days,
    required DateTime now,
    Locale? locale,
    String locationLabel = '',
  }) async {
    final timeline = <Map<String, Object>>[];
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 3));

    for (final day in days) {
      final safeDay = DateTime(day.date.year, day.date.month, day.date.day);
      if (safeDay.isBefore(start) || safeDay.isAfter(end)) {
        continue;
      }
      final prayerTimes = prayerMapForDay(day);
      for (final prayerName in prayerOrder) {
        final prayerTime = parsePrayerTime(day.date, prayerTimes[prayerName] ?? '');
        if (prayerTime == null || !prayerTime.isAfter(now)) {
          continue;
        }
        timeline.add(<String, Object>{
          'name': localizedPrayerName(locale, prayerName),
          'epochMs': prayerTime.millisecondsSinceEpoch,
        });
      }
    }

    if (timeline.isEmpty) {
      for (final day in days) {
        final prayerTimes = prayerMapForDay(day);
        for (final prayerName in prayerOrder) {
          final prayerTime =
              parsePrayerTime(day.date, prayerTimes[prayerName] ?? '');
          if (prayerTime == null) {
            continue;
          }
          timeline.add(<String, Object>{
            'name': localizedPrayerName(locale, prayerName),
            'epochMs': prayerTime.millisecondsSinceEpoch,
          });
          break;
        }
        if (timeline.isNotEmpty) {
          break;
        }
      }
    }

    final todayPrayers = <Map<String, Object>>[];
    for (final day in days) {
      final safeDay = DateTime(day.date.year, day.date.month, day.date.day);
      if (safeDay != start) {
        continue;
      }
      final prayerTimes = prayerMapForDay(day);
      for (final prayerName in prayerOrder) {
        final prayerTime = parsePrayerTime(day.date, prayerTimes[prayerName] ?? '');
        if (prayerTime == null) {
          continue;
        }
        todayPrayers.add(<String, Object>{
          'name': localizedPrayerName(locale, prayerName),
          'rawName': prayerName.toLowerCase(),
          'epochMs': prayerTime.millisecondsSinceEpoch,
        });

      }
      break;
    }

    await _channel.invokeMethod<void>('updateWidgetData', <String, Object>{
      'timeline': timeline,
      'todayPrayers': todayPrayers,
      'locationLabel': locationLabel,
      'appLocale': locale?.languageCode ?? '',
    });
  }

  Future<void> updateWidgetLocale(String localeCode) async {
    await _channel.invokeMethod<void>('updateWidgetLocale', <String, Object>{
      'locale': localeCode,
    });
  }

  Future<void> updateCalendarReminders({
    required String headerText,
    required List<Map<String, Object>> reminders,
  }) async {
    await _channel.invokeMethod<void>('updateCalendarReminders', <String, Object>{
      'headerText': headerText,
      'reminders': reminders,
    });
  }

  Future<void> updateWidgetTextSize(String size) async {
    await _channel.invokeMethod<void>('updateWidgetTextSize', <String, Object>{
      'size': size,
    });
  }

  /// Pushes the minutes threshold below which widgets count down in MM:SS
  /// instead of the minute-granularity HH:MM format (0-60).
  Future<void> updateWidgetMmssThreshold(int minutes) async {
    await _channel.invokeMethod<void>(
      'updateWidgetMmssThreshold',
      <String, Object>{'minutes': minutes},
    );
  }

  Future<void> updateStatusBarConfig({
    required bool enabled,
    required bool autoRestore,
  }) async {
    await _channel.invokeMethod<void>('updateStatusBarConfig', <String, Object>{
      'enabled': enabled,
      'autoRestore': autoRestore,
    });
  }

  void registerOpenHomeHandler(VoidCallback onOpenHome) {
    if (_hasHomeListener) {
      return;
    }
    _hasHomeListener = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openHomeTab') {
        onOpenHome();
      }
    });
    _consumePendingOpenHome(onOpenHome);
  }

  Future<void> _consumePendingOpenHome(VoidCallback onOpenHome) async {
    final shouldOpen =
        await _channel.invokeMethod<bool>('consumePendingOpenHome') ?? false;
    if (shouldOpen) {
      onOpenHome();
    }
  }
}
