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

