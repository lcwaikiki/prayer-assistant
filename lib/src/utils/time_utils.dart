import 'package:intl/intl.dart';

import '../models/prayer_models.dart';

const prayerOrder = <String>[
  'Imsak',
  'Gunes',
  'Ogle',
  'Ikindi',
  'Aksam',
  'Yatsi',
];

Map<String, String> prayerMapForDay(PrayerDay day) {
  return {
    'Imsak': day.imsak,
    'Gunes': day.gunes,
    'Ogle': day.ogle,
    'Ikindi': day.ikindi,
    'Aksam': day.aksam,
    'Yatsi': day.yatsi,
  };
}

DateTime? parsePrayerTime(DateTime baseDate, String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) {
    return null;
  }
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }
  return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
}

String formatRemaining(Duration duration) {
  final totalSeconds = duration.inSeconds.clamp(0, 999999);
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '$hours:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:'
      '${seconds.toString().padLeft(2, '0')}';
}

String buildSharePrayerTimesText({
  required SelectedLocation location,
  required PrayerDay day,
  required String Function(String prayerName) label,
}) {
  final buffer = StringBuffer()
    ..writeln(location.fullName)
    ..writeln(DateFormat('EEEE, dd MMM yyyy').format(day.date))
    ..writeln(day.hijriDate);
  for (final name in prayerOrder) {
    buffer.writeln('${label(name)}: ${prayerMapForDay(day)[name] ?? '--:--'}');
  }
  return buffer.toString();
}
