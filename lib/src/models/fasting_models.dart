import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';

enum FastingType {
  ramadan,
  sunnah,
  qadaa,
}

@immutable
class FastingLog {
  const FastingLog({
    required this.dateKey,
    required this.type,
    this.notes = '',
  });

  /// Date string formatted as yyyy-MM-dd.
  final String dateKey;
  final FastingType type;
  final String notes;

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'type': type.name,
      'notes': notes,
    };
  }

  factory FastingLog.fromMap(Map<String, dynamic> map) {
    return FastingLog(
      dateKey: map['dateKey'] as String? ?? '',
      type: FastingType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => FastingType.sunnah,
      ),
      notes: map['notes'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastingLog &&
          runtimeType == other.runtimeType &&
          dateKey == other.dateKey &&
          type == other.type &&
          notes == other.notes;

  @override
  int get hashCode => dateKey.hashCode ^ type.hashCode ^ notes.hashCode;
}

enum SunnahCategory {
  mondayThursday,
  whiteDays,
  ashura,
  arafah,
  ramadan,
}

@immutable
class SunnahDayInfo {
  const SunnahDayInfo({
    required this.date,
    required this.categories,
    required this.descriptionKey,
  });

  final DateTime date;
  final List<SunnahCategory> categories;
  final String descriptionKey;

  static SunnahDayInfo? checkDate(DateTime date) {
    final hDate = HijriCalendar.fromDate(date);
    final categories = <SunnahCategory>[];

    // Check Ramadan (Month 9)
    if (hDate.hMonth == 9) {
      categories.add(SunnahCategory.ramadan);
    }

    // Check Ashura (10th Muharram - Month 1)
    if (hDate.hMonth == 1 && hDate.hDay == 10) {
      categories.add(SunnahCategory.ashura);
    }

    // Check Arafah (9th Dhu al-Hijjah - Month 12)
    if (hDate.hMonth == 12 && hDate.hDay == 9) {
      categories.add(SunnahCategory.arafah);
    }

    // Check White Days (13th, 14th, 15th Hijri days, except Month 12 day 13 Tashreeq)
    if ((hDate.hDay == 13 || hDate.hDay == 14 || hDate.hDay == 15) &&
        !(hDate.hMonth == 12 && hDate.hDay == 13)) {
      categories.add(SunnahCategory.whiteDays);
    }

    // Check Monday & Thursday
    if (date.weekday == DateTime.monday || date.weekday == DateTime.thursday) {
      categories.add(SunnahCategory.mondayThursday);
    }

    if (categories.isEmpty) return null;

    String descKey = 'sunnahFast';
    if (categories.contains(SunnahCategory.ramadan)) {
      descKey = 'ramadanFast';
    } else if (categories.contains(SunnahCategory.arafah)) {
      descKey = 'arafahFast';
    } else if (categories.contains(SunnahCategory.ashura)) {
      descKey = 'ashuraFast';
    } else if (categories.contains(SunnahCategory.whiteDays)) {
      descKey = 'whiteDaysFast';
    } else if (categories.contains(SunnahCategory.mondayThursday)) {
      descKey = 'mondayThursdayFast';
    }

    return SunnahDayInfo(
      date: date,
      categories: categories,
      descriptionKey: descKey,
    );
  }
}
