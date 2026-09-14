import 'package:bizops360_mobile/core/error/failure.dart';
import 'package:bizops360_mobile/core/error/result.dart';
import 'package:bizops360_mobile/core/location/location_fix.dart';
import 'package:bizops360_mobile/core/location/location_service.dart';
import 'package:bizops360_mobile/data/repositories/fake_attendance_repository.dart';
import 'package:bizops360_mobile/data/repositories/fake_office_location_repository.dart';
import 'package:bizops360_mobile/domain/entities/attendance.dart';
import 'package:bizops360_mobile/presentation/hr/controllers/attendance_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedLocationService implements LocationService {
  const _FixedLocationService(this.fix);
  final LocationFix fix;

  @override
  Future<Result<LocationFix>> current() async => Result.ok(fix);
}

class _DeniedLocationService implements LocationService {
  const _DeniedLocationService();

  @override
  Future<Result<LocationFix>> current() async =>
      const Result.err(UnknownFailure('Location permission is required.'));
}

void main() {
  test('punching from inside the geofence tags the punch Office', () async {
    final c = AttendanceController(
      FakeAttendanceRepository(),
      FakeOfficeLocationRepository(),
      const _FixedLocationService(LocationFix(23.7808, 90.4145)),
    );
    await c.load();

    await c.punch();

    expect(c.today.value.valueOrNull!.checkInZone, PunchZone.office);
    expect(c.locationError.value, isNull);
  });

  test(
    'punching far from the office tags the punch Outside, not blocked',
    () async {
      final c = AttendanceController(
        FakeAttendanceRepository(),
        FakeOfficeLocationRepository(),
        const _FixedLocationService(LocationFix(23.9, 90.6)),
      );
      await c.load();

      await c.punch();

      expect(c.today.value.valueOrNull!.checkInZone, PunchZone.outside);
      expect(c.today.value.valueOrNull!.isCheckedIn, isTrue);
    },
  );

  test(
    'without a location fix the punch is blocked and an error is shown',
    () async {
      final c = AttendanceController(
        FakeAttendanceRepository(),
        FakeOfficeLocationRepository(),
        const _DeniedLocationService(),
      );
      await c.load();

      await c.punch();

      expect(c.today.value.valueOrNull!.checkIn, isNull);
      expect(c.locationError.value, isNotNull);
    },
  );
}
