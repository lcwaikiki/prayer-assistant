import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Initializes the timezone database and sets the local location.
///
/// Must run in every isolate that schedules timezone-aware notifications.
/// Background alarm callbacks (the midnight refresh schedulers) run in
/// fresh isolates that don't inherit the main isolate's timezone state,
/// where accessing `tz.local` before this throws LateInitializationError.
/// Safe to call repeatedly.
Future<void> initializeLocalTimezone() async {
  tz.initializeTimeZones();
  try {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }
}
