import 'package:hijri/hijri_calendar.dart';

const _enWeekdays = <int, String>{
  7: 'Sunday',
  1: 'Monday',
  2: 'Tuesday',
  3: 'Wednesday',
  4: 'Thursday',
  5: 'Friday',
  6: 'Saturday',
};

const _enShortWeekdays = <int, String>{
  7: 'Sun',
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
};

const _enShortMonths = <int, String>{
  1: 'Muh',
  2: 'Saf',
  3: 'Rab1',
  4: 'Rab2',
  5: 'Jum1',
  6: 'Jum2',
  7: 'Raj',
  8: 'Shb',
  9: 'Ram',
  10: 'Shw',
  11: 'DhQ',
  12: 'DhH',
};

/// Maps app language codes to hijri-package locale codes, registering
/// custom month-name maps for languages the package does not natively
/// support (ar, en, tr are built-in).
final _localeMap = <String, String>{
  'de': 'de',
  'es': 'es',
  'fa': 'fa',
  'fr': 'fr',
  'id': 'id',
  'ja': 'ja',
  'ru': 'ru',
  'ur': 'ur',
  'zh': 'zh',
};

final _monthNames = <String, Map<int, String>>{
  'de': {
    1: 'Muharram',
    2: 'Safar',
    3: "Rabi' I",
    4: "Rabi' II",
    5: 'Dschumada I',
    6: 'Dschumada II',
    7: 'Radschab',
    8: "Scha'ban",
    9: 'Ramadan',
    10: 'Schawwal',
    11: "Dhu l-Qa'da",
    12: "Dhu l-Hiddscha",
  },
  'es': {
    1: 'Muharram',
    2: 'Safar',
    3: "Rabi' I",
    4: "Rabi' II",
    5: 'Yumada I',
    6: 'Yumada II',
    7: 'Rajab',
    8: "Sha'ban",
    9: 'Ramadan',
    10: 'Shawwal',
    11: "Dhul Qa'da",
    12: 'Dhul Hijjah',
  },
  'fa': {
    1: 'محرم',
    2: 'صفر',
    3: 'ربیع‌الاول',
    4: 'ربیع‌الثانی',
    5: 'جمادی‌الاول',
    6: 'جمادی‌الثانی',
    7: 'رجب',
    8: 'شعبان',
    9: 'رمضان',
    10: 'شوال',
    11: 'ذی‌القعده',
    12: 'ذی‌الحجه',
  },
  'fr': {
    1: 'Muharram',
    2: 'Safar',
    3: "Rabi' al-Awwal",
    4: "Rabi' al-Thani",
    5: 'Jumada al-Awwal',
    6: 'Jumada al-Thani',
    7: 'Rajab',
    8: "Cha'ban",
    9: 'Ramadan',
    10: 'Chawwal',
    11: "Dhou al-Qi'da",
    12: 'Dhou al-Hijja',
  },
  'id': {
    1: 'Muharram',
    2: 'Safar',
    3: "Rabi'ul Awal",
    4: "Rabi'ul Akhir",
    5: 'Jumadil Awal',
    6: 'Jumadil Akhir',
    7: 'Rajab',
    8: "Sya'ban",
    9: 'Ramadan',
    10: 'Syawal',
    11: "Dzulqa'dah",
    12: 'Dzulhijjah',
  },
  'ja': {
    1: 'ムハッラム',
    2: 'サファル',
    3: 'ラビー・アル＝アウワル',
    4: 'ラビー・アル＝サーニー',
    5: 'ジュマーダー・アル＝ウーラー',
    6: 'ジュマーダー・アル＝サーニー',
    7: 'ラジャブ',
    8: 'シャアバーン',
    9: 'ラマダーン',
    10: 'シャウワール',
    11: 'ズル＝カアダ',
    12: 'ズル＝ヒッジャ',
  },
  'ru': {
    1: 'Мухаррам',
    2: 'Сафар',
    3: 'Раби аль-авваль',
    4: 'Раби ас-сани',
    5: 'Джумада аль-уля',
    6: 'Джумада ас-сани',
    7: 'Раджаб',
    8: 'Шаабан',
    9: 'Рамадан',
    10: 'Шавваль',
    11: 'Зуль-каада',
    12: 'Зуль-хиджа',
  },
  'ur': {
    1: 'محرم',
    2: 'صفر',
    3: 'ربیع الاول',
    4: 'ربیع الثانی',
    5: 'جمادی الاول',
    6: 'جمادی الثانی',
    7: 'رجب',
    8: 'شعبان',
    9: 'رمضان',
    10: 'شوال',
    11: 'ذوالقعدہ',
    12: 'ذوالحجہ',
  },
  'zh': {
    1: '穆哈兰姆月',
    2: '萨法尔月',
    3: '拉比·阿瓦尔月',
    4: '拉比·萨尼月',
    5: '朱马达·阿瓦尔月',
    6: '朱马达·萨尼月',
    7: '拉贾布月',
    8: '沙班月',
    9: '赖买丹月',
    10: '闪瓦鲁月',
    11: '祖勒·盖阿德月',
    12: '祖勒·哈吉月',
  },
};

/// Whether [HijriCalendar.addLocale] has been called for all custom
/// languages. Registration is only needed once per process.
bool _localesRegistered = false;

void _ensureLocalesRegistered() {
  if (_localesRegistered) {
    return;
  }
  for (final entry in _monthNames.entries) {
    HijriCalendar.addLocale(entry.key, {
      'long': entry.value,
      'short': _enShortMonths,
      'days': _enWeekdays,
      'short_days': _enShortWeekdays,
    });
  }
  _localesRegistered = true;
}

/// The hijri-package locale code to use for [languageCode]. The package
/// natively supports ar, en, tr; all other app languages use custom
/// month-name maps registered via [_ensureLocalesRegistered].
String _hijriLocale(String languageCode) {
  if (languageCode == 'ar' || languageCode == 'en' || languageCode == 'tr') {
    return languageCode;
  }
  final mapped = _localeMap[languageCode];
  if (mapped != null) {
    _ensureLocalesRegistered();
    return mapped;
  }
  return 'en';
}

/// Returns a localized Hijri date string for [date] in the given
/// [languageCode], e.g. "1 Muharram 1446" for English or "1 محرم ١٤٤٦"
/// for Arabic.
String formatHijriDate(DateTime date, String languageCode) {
  final hijri = HijriCalendar.fromDate(date);
  final code = _hijriLocale(languageCode);
  HijriCalendar.language = code;
  final cal = HijriCalendar()
    ..hYear = hijri.hYear
    ..hMonth = hijri.hMonth;
  final monthName = cal.getLongMonthName();
  final dayStr =
      code == 'ar' ? _toArabicNumerals(hijri.hDay) : hijri.hDay.toString();
  final yearStr =
      code == 'ar' ? _toArabicNumerals(hijri.hYear) : hijri.hYear.toString();
  return '$dayStr $monthName $yearStr';
}

String _toArabicNumerals(int n) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((c) {
    final d = int.tryParse(c);
    return d != null ? arabicDigits[d] : c;
  }).join();
}

class _IslamicHoliday {
  const _IslamicHoliday(this.hijriMonth, this.hijriDay, this.labelKey);

  final int hijriMonth;
  final int hijriDay;
  final String labelKey;
}

const _holidays = <_IslamicHoliday>[
  _IslamicHoliday(1, 1, 'holiday_islamic_new_year'),
  _IslamicHoliday(1, 10, 'holiday_ashura'),
  _IslamicHoliday(3, 12, 'holiday_mawlid'),
  _IslamicHoliday(7, 27, 'holiday_isra_miraj'),
  _IslamicHoliday(8, 15, 'holiday_laylat_barat'),
  _IslamicHoliday(9, 1, 'holiday_ramadan_first'),
  _IslamicHoliday(9, 27, 'holiday_laylat_qadr'),
  _IslamicHoliday(10, 1, 'holiday_eid_fitr'),
  _IslamicHoliday(12, 9, 'holiday_arafah'),
  _IslamicHoliday(12, 10, 'holiday_eid_adha'),
];

/// Returns the key for the Islamic holiday label on [date] based on its
/// Hijri month and day, or null if the date is not a holiday.
String? islamicHolidayKey(DateTime date) {
  final hijri = HijriCalendar.fromDate(date);
  for (final holiday in _holidays) {
    if (hijri.hMonth == holiday.hijriMonth &&
        hijri.hDay == holiday.hijriDay) {
      return holiday.labelKey;
    }
  }
  return null;
}

/// Returns the name of the Islamic holiday on [date] based on its Hijri
/// month and day, or null if the date is not a holiday.
/// [labelResolver] translates the holiday key to a localized string.
String? islamicHolidayForDate(
  DateTime date,
  String Function(String key) labelResolver,
) {
  final key = islamicHolidayKey(date);
  return key != null ? labelResolver(key) : null;
}

/// A Hijri year/month pair, independent of any specific day.
class HijriMonth {
  const HijriMonth(this.year, this.month);

  final int year;
  final int month;

  DateTime get gregorianStart =>
      HijriCalendar().hijriToGregorian(year, month, 1);

  int get daysInMonth => HijriCalendar().getDaysInMonth(year, month);

  /// Returns the month's display name for [languageCode], using translated
  /// names for all supported app locales.
  String longMonthName(String languageCode) {
    HijriCalendar.language = _hijriLocale(languageCode);
    final calendar = HijriCalendar()
      ..hYear = year
      ..hMonth = month;
    return calendar.getLongMonthName();
  }

  HijriMonth shift(int delta) {
    final total = (year * 12 + (month - 1)) + delta;
    final normalizedMonth = total % 12;
    final wrappedMonth =
        normalizedMonth < 0 ? normalizedMonth + 12 : normalizedMonth;
    final wrappedYear = (total - wrappedMonth) ~/ 12;
    return HijriMonth(wrappedYear, wrappedMonth + 1);
  }

  static HijriMonth fromDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    return HijriMonth(hijri.hYear, hijri.hMonth);
  }
}
