import 'dart:math';

const meccaLatitude = 21.4225;
const meccaLongitude = 39.8262;

/// Great-circle initial bearing from [lat]/[lon] to Mecca, in degrees
/// clockwise from true north (0-360).
double qiblaBearing(double lat, double lon) {
  final phi1 = lat * pi / 180;
  final phi2 = meccaLatitude * pi / 180;
  final deltaLambda = (meccaLongitude - lon) * pi / 180;
  final y = sin(deltaLambda);
  final x = cos(phi1) * tan(phi2) - sin(phi1) * cos(deltaLambda);
  final bearing = atan2(y, x) * 180 / pi;
  return (bearing + 360) % 360;
}

/// Great-circle distance from [lat]/[lon] to Mecca in kilometers.
double distanceToMeccaKm(double lat, double lon) {
  const earthRadiusKm = 6371.0;
  final dLat = (meccaLatitude - lat) * pi / 180;
  final dLon = (meccaLongitude - lon) * pi / 180;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat * pi / 180) *
          cos(meccaLatitude * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

/// Calculate solar azimuth (0-360 degrees from True North) and elevation for [lat]/[lon] at [time].
({double azimuth, double elevation}) sunPosition(
  double lat,
  double lon, [
  DateTime? time,
]) {
  final now = (time ?? DateTime.now()).toUtc();
  final epochMillis = now.millisecondsSinceEpoch;
  final jd = 2440587.5 + epochMillis / 86400000.0;
  final t = (jd - 2451545.0) / 36525.0;

  final l0 = (280.46646 + t * (36000.76983 + t * 0.0003032)) % 360;
  final m = (357.52911 + t * (35999.05029 - 0.0001537 * t)) % 360;
  final mRad = m * pi / 180;

  final c = sin(mRad) * (1.914602 - t * (0.004817 + 0.000014 * t)) +
      sin(2 * mRad) * (0.019993 - 0.000101 * t) +
      sin(3 * mRad) * 0.000289;

  final sunTrueLong = (l0 + c) % 360;
  final sunTrueLongRad = sunTrueLong * pi / 180;

  final eps0 = (23.439291 - 0.0130042 * t) * pi / 180;
  final sinDelta = sin(eps0) * sin(sunTrueLongRad);
  final delta = asin(sinDelta);
  final cosDelta = cos(delta);

  final alpha = atan2(cos(eps0) * sin(sunTrueLongRad), cos(sunTrueLongRad)) *
      180 /
      pi;

  final gmst = (280.46061837 + 360.98564736629 * (jd - 2451545.0)) % 360;
  final localHourAngle = ((gmst + lon - alpha) % 360 + 360) % 360;
  final hRad = localHourAngle * pi / 180;
  final latRad = lat * pi / 180;

  final sinElevation = sin(latRad) * sin(delta) + cos(latRad) * cosDelta * cos(hRad);
  final elevation = asin(sinElevation.clamp(-1.0, 1.0)) * 180 / pi;

  final y = -cosDelta * sin(hRad);
  final x = sin(delta) * cos(latRad) - cosDelta * sin(latRad) * cos(hRad);
  final azimuth = (atan2(y, x) * 180 / pi + 360) % 360;

  return (azimuth: azimuth, elevation: elevation);
}

