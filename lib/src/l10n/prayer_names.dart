import 'dart:ui';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

extension PrayerNamesL10n on AppLocalizations {
  String prayerNameLabel(String key) {
    return switch (key.toLowerCase()) {
      'imsak' || 'fajr' => imsak,
      'gunes' || 'sunrise' => gunes,
      'ogle' || 'dhuhr' => ogle,
      'ikindi' || 'asr' => ikindi,
      'aksam' || 'maghrib' => aksam,
      'yatsi' || 'isha' => yatsi,
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
      lower.contains('ফজর') ||
      lower.contains('ஃபஜ்ர்') ||
      lower.contains('sabah')) {
    return Icons.wb_twilight;
  }
  if (lower.contains('gunes') ||
      lower.contains('sunrise') ||
      lower.contains('شروق') ||
      lower.contains('সূর্যোদয়') ||
      lower.contains('சூரியோதயம்')) {
    return Icons.wb_sunny_outlined;
  }
  if (lower.contains('ogle') ||
      lower.contains('dhuhr') ||
      lower.contains('zuhr') ||
      lower.contains('ظهر') ||
      lower.contains('যোহর') ||
      lower.contains('ளுஹர்')) {
    return Icons.wb_sunny;
  }
  if (lower.contains('ikindi') ||
      lower.contains('asr') ||
      lower.contains('عصر') ||
      lower.contains('আসর') ||
      lower.contains('அஸ்ர்')) {
    return Icons.wb_twilight_outlined;
  }
  if (lower.contains('aksam') ||
      lower.contains('maghrib') ||
      lower.contains('مغرب') ||
      lower.contains('মাগরিব') ||
      lower.contains('மஃக்ரிப்')) {
    return Icons.nights_stay_outlined;
  }
  if (lower.contains('yatsi') ||
      lower.contains('isha') ||
      lower.contains('عشاء') ||
      lower.contains('ইশা') ||
      lower.contains('இஷா')) {
    return Icons.nights_stay;
  }
  if (lower.contains('witr') ||
      lower.contains('vitir') ||
      lower.contains('وتر') ||
      lower.contains('বিতর') ||
      lower.contains('வித்ர்')) {
    return Icons.star_outline;
  }
  return Icons.access_time;
}
