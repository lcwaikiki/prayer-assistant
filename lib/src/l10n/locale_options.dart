import 'package:flutter/material.dart';

import '../models/prayer_models.dart';

const supportedAppLocales = <Locale>[
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('de'),
  Locale('tr'),
  Locale('ur'),
  Locale('fa'),
  Locale('ar'),
  Locale('zh'),
  Locale('ja'),
  Locale('id'),
];

extension AppLocalePreferenceX on AppLocalePreference {
  Locale? get locale {
    if (this == AppLocalePreference.system) {
      return null;
    }
    return Locale(name);
  }

  String nativeLabel(String systemDefaultLabel) {
    if (this == AppLocalePreference.system) {
      return systemDefaultLabel;
    }
    return switch (this) {
      AppLocalePreference.en => 'English',
      AppLocalePreference.es => 'Español',
      AppLocalePreference.fr => 'Français',
      AppLocalePreference.de => 'Deutsch',
      AppLocalePreference.tr => 'Türkçe',
      AppLocalePreference.ur => 'اردو',
      AppLocalePreference.fa => 'فارسی',
      AppLocalePreference.ar => 'العربية',
      AppLocalePreference.zh => '中文',
      AppLocalePreference.ja => '日本語',
      AppLocalePreference.id => 'Bahasa Indonesia',
      AppLocalePreference.system => systemDefaultLabel,
    };
  }
}
