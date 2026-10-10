import 'dart:ui';

import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';

import '../calendar/moon_phase_utils.dart';
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
    String dateHeaderHijri = '',
    String dateHeaderGregorian = '',
    String calendarDisplay = 'hijri',
    bool showSecondaryCalendarDate = true,
    String weekStart = 'monday',
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

    final moonInfo = getMoonPhase(now);
    final safeLocale = (locale != null && locale.languageCode.isNotEmpty)
        ? locale
        : const Locale('en');
    AppLocalizations l10n;
    try {
      l10n = lookupAppLocalizations(safeLocale);
    } catch (_) {
      l10n = AppLocalizationsEn();
    }
    final localizedPhaseName = _getLocalizedPhaseName(l10n, moonInfo.phaseNameKey);
    final whiteDayBadgeText = l10n.whiteDaysTitle;


    await _channel.invokeMethod<void>('updateWidgetData', <String, Object>{
      'timeline': timeline,
      'todayPrayers': todayPrayers,
      'locationLabel': locationLabel,
      'appLocale': locale?.languageCode ?? '',
      'dateHeaderHijri': dateHeaderHijri,
      'dateHeaderGregorian': dateHeaderGregorian,
      'calendarDisplay': calendarDisplay,
      'showSecondaryDate': showSecondaryCalendarDate,
      'weekStart': weekStart,
      'moonPhaseValue': moonInfo.phaseValue,
      'moonIllumination': moonInfo.illumination,
      'moonIlluminationText': l10n.moonIllumination(
        moonInfo.illumination.round(),
      ),
      'moonPhaseName': localizedPhaseName,
      'moonHijriDate': dateHeaderHijri,
      'moonGregorianDate': dateHeaderGregorian,
      'isWhiteDay': moonInfo.isWhiteDay,
      'whiteDayBadgeText': whiteDayBadgeText,
    });
  }

  String _getLocalizedPhaseName(AppLocalizations l10n, String key) {
    switch (key) {
      case 'moonPhaseNewMoon':
        return l10n.moonPhaseNewMoon;
      case 'moonPhaseWaxingCrescent':
        return l10n.moonPhaseWaxingCrescent;
      case 'moonPhaseFirstQuarter':
        return l10n.moonPhaseFirstQuarter;
      case 'moonPhaseWaxingGibbous':
        return l10n.moonPhaseWaxingGibbous;
      case 'moonPhaseFullMoon':
        return l10n.moonPhaseFullMoon;
      case 'moonPhaseWaningGibbous':
        return l10n.moonPhaseWaningGibbous;
      case 'moonPhaseLastQuarter':
        return l10n.moonPhaseLastQuarter;
      case 'moonPhaseWaningCrescent':
        return l10n.moonPhaseWaningCrescent;
      default:
        return l10n.moonPhaseTitle;

    }
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

  /// Sends today's qadaa progress and the widget's localized labels.
  Future<void> updateQadaaWidget({
    required String dateKey,
    required int todayCount,
    required int goal,
    required int remaining,
    required String title,
    required String remainingLabel,
    required String addDayLabel,
  }) async {
    await _channel.invokeMethod<void>('updateQadaaWidget', <String, Object>{
      'dateKey': dateKey,
      'todayCount': todayCount,
      'goal': goal,
      'remaining': remaining,
      'title': title,
      'remainingLabel': remainingLabel,
      'addDayLabel': addDayLabel,
    });
  }

  /// Returns "+1 full day" taps queued by the qadaa widget (dateKey -> days)
  /// and clears the queue.
  Future<Map<String, int>> consumeQadaaPending() async {
    final pending = await _channel.invokeMapMethod<String, int>(
      'consumeQadaaPending',
    );
    return pending ?? const {};
  }

  Future<void> updateWidgetTextSize(String size) async {
    await _channel.invokeMethod<void>('updateWidgetTextSize', <String, Object>{
      'size': size,
    });
  }

  Future<void> updateWidgetTheme(String theme) async {
    await _channel.invokeMethod<void>('updateWidgetTheme', <String, Object>{
      'theme': theme,
    });
  }

  Future<void> updateWidgetCalendarDisplay(
    String display,
    bool showSecondaryDate,
  ) async {
    await _channel.invokeMethod<void>(
      'updateWidgetCalendarDisplay',
      <String, Object>{
        'display': display,
        'showSecondaryDate': showSecondaryDate,
      },
    );
  }

  /// Pushes the minutes threshold below which widgets count down in MM:SS
  /// instead of the minute-granularity HH:MM format (0-60).
  Future<void> updateWidgetMmssThreshold(int minutes) async {
    await _channel.invokeMethod<void>(
      'updateWidgetMmssThreshold',
      <String, Object>{'minutes': minutes},
    );
  }

  Future<void> updateSnoozeDurationMinutes(int minutes) async {
    try {
      await _channel.invokeMethod<void>(
        'updateSnoozeDurationMinutes',
        <String, Object>{'minutes': minutes},
      );
    } catch (_) {}
  }

  Future<void> updateDismissConfirm(bool enabled) async {
    try {
      await _channel.invokeMethod<void>(
        'updateDismissConfirm',
        <String, Object>{'dismissConfirm': enabled},
      );
    } catch (_) {}
  }

  Future<void> updateStatusBarConfig({
    required bool enabled,
    required bool autoRestore,
    bool showTimeLeft = true,
    bool showPrayerTimes = true,
  }) async {
    await _channel.invokeMethod<void>('updateStatusBarConfig', <String, Object>{
      'enabled': enabled,
      'autoRestore': autoRestore,
      'showTimeLeft': showTimeLeft,
      'showPrayerTimes': showPrayerTimes,
    });
  }

  /// Calls [onOpenTarget] with the screen a tapped widget or the status bar
  /// asks for ('today', 'dates', 'fasting' or 'qadaa'), including a tap
  /// that launched the app before this handler was registered.
  void registerOpenTargetHandler(ValueChanged<String> onOpenTarget) {
    if (_hasHomeListener) {
      return;
    }
    _hasHomeListener = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openTarget') {
        onOpenTarget(call.arguments as String);
      }
    });
    _consumePendingOpenTarget(onOpenTarget);
  }

  Future<void> _consumePendingOpenTarget(
    ValueChanged<String> onOpenTarget,
  ) async {
    final target = await _channel.invokeMethod<String>(
      'consumePendingOpenTarget',
    );
    if (target != null) {
      onOpenTarget(target);
    }
  }
}
