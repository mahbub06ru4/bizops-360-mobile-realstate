import '../error/result.dart';
import 'location_fix.dart';
import 'location_service.dart';

/// Always answers with a fixed fix inside the seeded office geofence — good
/// enough for UI-first development without touching platform location APIs.
class FakeLocationService implements LocationService {
  const FakeLocationService([this.fix = const LocationFix(23.7808, 90.4145)]);

  final LocationFix fix;

  @override
  Future<Result<LocationFix>> current() =>
      Future.delayed(const Duration(milliseconds: 200), () => Result.ok(fix));
}
