import 'dart:ui';

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
