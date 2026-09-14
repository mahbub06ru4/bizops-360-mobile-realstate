import '../error/result.dart';
import 'location_fix.dart';

/// A single current-position read, abstracted away from `package:geolocator`
/// so controllers stay testable without a platform channel.
abstract interface class LocationService {
  Future<Result<LocationFix>> current();
}
