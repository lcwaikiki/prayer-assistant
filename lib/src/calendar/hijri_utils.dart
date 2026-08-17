import 'package:hijri/hijri_calendar.dart';

/// A Hijri year/month pair, independent of any specific day.
class HijriMonth {
  const HijriMonth(this.year, this.month);

  final int year;
  final int month;

  DateTime get gregorianStart =>
      HijriCalendar().hijriToGregorian(year, month, 1);

  int get daysInMonth => HijriCalendar().getDaysInMonth(year, month);

  /// The month's display name for [languageCode]. The hijri package reads
  /// names from a static locale that defaults to English, so it must be
  /// switched per app locale: Arabic gets the native names, other locales
  /// get the standard transliterations.
  String longMonthName(String languageCode) {
    HijriCalendar.language = languageCode == 'ar' ? 'ar' : 'en';
    final calendar = HijriCalendar()
      ..hYear = year
      ..hMonth = month;
    return calendar.getLongMonthName();
  }

  HijriMonth shift(int delta) {
    final total = (year * 12 + (month - 1)) + delta;
    final normalizedMonth = total % 12;
    final wrappedMonth = normalizedMonth < 0 ? normalizedMonth + 12 : normalizedMonth;
    final wrappedYear = (total - wrappedMonth) ~/ 12;
    return HijriMonth(wrappedYear, wrappedMonth + 1);
  }

  static HijriMonth fromDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    return HijriMonth(hijri.hYear, hijri.hMonth);
  }
}
