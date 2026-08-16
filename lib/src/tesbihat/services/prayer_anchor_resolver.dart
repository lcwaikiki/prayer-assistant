import '../../services/local_database.dart';
import '../../utils/time_utils.dart';

/// Resolves a prayer-anchored reminder's concrete fire time for [date]
/// (defaults to today), reading from the same cached prayer schedule the main
/// app uses. Returns null if there's no selected location, no cached data for
/// [date] yet, or [prayerName] isn't one of [prayerOrder]'s keys.
Future<DateTime?> resolvePrayerAnchoredTime(
  LocalDatabase database, {
  required String? prayerName,
  required int offsetMinutes,
  DateTime? date,
}) async {
  if (prayerName == null) {
    return null;
  }

  final selected = await database.loadSelectedLocation();
  if (selected == null) {
    return null;
  }

  final target = date ?? DateTime.now();
  final day = await database.getDay(
    districtId: selected.districtId,
    date: DateTime(target.year, target.month, target.day),
  );
  if (day == null) {
    return null;
  }

  final times = prayerMapForDay(day);
  final rawTime = times[prayerName];
  if (rawTime == null || rawTime.isEmpty) {
    return null;
  }

  final base = parsePrayerTime(day.date, rawTime);
  if (base == null) {
    return null;
  }

  return base.add(Duration(minutes: offsetMinutes));
}
