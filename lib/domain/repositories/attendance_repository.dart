import '../../core/error/result.dart';
import '../entities/attendance.dart';

abstract interface class AttendanceRepository {
  Future<Result<AttendanceToday>> today();

  /// Most-recent day first.
  Future<Result<List<AttendanceDay>>> history();

  /// [zone] is decided client-side from the device fix against the office
  /// geofence — punching is never blocked by distance, only tagged by it.
  Future<Result<AttendanceToday>> checkIn(PunchZone zone);

  Future<Result<AttendanceToday>> checkOut(PunchZone zone);
}
