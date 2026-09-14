import 'dart:math';

/// Great-circle distance in metres between two coordinates (haversine).
/// Accurate enough for a ~500m office geofence; avoids pulling the
/// `geolocator` plugin into anything but [GeolocatorLocationService].
double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusMeters = 6371000.0;
  final dLat = _radians(lat2 - lat1);
  final dLng = _radians(lng2 - lng1);
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_radians(lat1)) * cos(_radians(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusMeters * c;
}

double _radians(double degrees) => degrees * pi / 180;
