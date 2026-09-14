import 'package:geolocator/geolocator.dart';

import '../error/failure.dart';
import '../error/result.dart';
import 'location_fix.dart';
import 'location_service.dart';

class GeolocatorLocationService implements LocationService {
  @override
  Future<Result<LocationFix>> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const Result.err(
        UnknownFailure('Turn on location services to punch in or out.'),
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const Result.err(
        UnknownFailure('Location permission is required to punch in or out.'),
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return Result.ok(LocationFix(position.latitude, position.longitude));
    } on Object {
      return const Result.err(
        UnknownFailure("Couldn't get your location. Try again."),
      );
    }
  }
}
