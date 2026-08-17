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
