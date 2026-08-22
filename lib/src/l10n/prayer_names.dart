import 'dart:ui';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

extension PrayerNamesL10n on AppLocalizations {
  String prayerNameLabel(String key) {
    return switch (key) {
      'Imsak' => imsak,
      'Gunes' => gunes,
      'Ogle' => ogle,
      'Ikindi' => ikindi,
      'Aksam' => aksam,
      'Yatsi' => yatsi,
      _ => key,
    };
  }
}

String localizedPrayerName(Locale? locale, String key) {
  final l10n = lookupAppLocalizations(locale ?? PlatformDispatcher.instance.locale);
  return l10n.prayerNameLabel(key);
}

IconData iconForPrayer(String nameOrKey) {
  final lower = nameOrKey.toLowerCase();
  if (lower.contains('imsak') ||
      lower.contains('fajr') ||
      lower.contains('فجر') ||
      lower.contains('sabah')) {
    return Icons.wb_twilight;
  }
  if (lower.contains('gunes') ||
      lower.contains('sunrise') ||
      lower.contains('شروق')) {
    return Icons.wb_sunny_outlined;
  }
  if (lower.contains('ogle') ||
      lower.contains('dhuhr') ||
      lower.contains('zuhr') ||
      lower.contains('ظهر')) {
    return Icons.wb_sunny;
  }
  if (lower.contains('ikindi') ||
      lower.contains('asr') ||
      lower.contains('عصر')) {
    return Icons.wb_twilight_outlined;
  }
  if (lower.contains('aksam') ||
      lower.contains('maghrib') ||
      lower.contains('مغرب')) {
    return Icons.nights_stay_outlined;
  }
  if (lower.contains('yatsi') ||
      lower.contains('isha') ||
      lower.contains('عشاء')) {
    return Icons.nights_stay;
  }
  if (lower.contains('witr') ||
      lower.contains('vitir') ||
      lower.contains('وتر')) {
    return Icons.star_outline;
  }
  return Icons.access_time;
}
