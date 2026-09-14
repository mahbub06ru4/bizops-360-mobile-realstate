import '../../core/error/result.dart';
import '../../domain/entities/office_location.dart';
import '../../domain/repositories/office_location_repository.dart';

/// In-memory office geofence for UI-first development — seeded near House 1,
/// Road 1, Gulshan-1, Dhaka.
class FakeOfficeLocationRepository implements OfficeLocationRepository {
  OfficeLocation _office = const OfficeLocation(
    label: 'House 1, Road 1, Gulshan-1, Dhaka',
    latitude: 23.7808,
    longitude: 90.4145,
    radiusMeters: 500,
    startTime: '10:00',
    endTime: '18:00',
  );

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 300), () => value);

  @override
  Future<Result<OfficeLocation>> get() => _delayed(Result.ok(_office));

  @override
  Future<Result<OfficeLocation>> update(OfficeLocation location) {
    _office = location;
    return _delayed(Result.ok(_office));
  }
}
