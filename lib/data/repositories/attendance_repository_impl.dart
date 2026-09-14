import '../../core/error/result.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/hr_remote_datasource.dart';
import '../models/hr_mappers.dart';
import 'remote_guard.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._remote);

  final HrRemoteDataSource _remote;

  @override
  Future<Result<AttendanceToday>> today() {
    return guardRequest(
      () async => attendanceTodayFrom(await _remote.attendance()),
    );
  }

  @override
  Future<Result<List<AttendanceDay>>> history() {
    return guardRequest(
      () async => (await _remote.attendance())
          .map(attendanceDayFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<AttendanceToday>> checkIn(PunchZone zone) {
    return guardRequest(
      () async =>
          attendanceTodayFromResource(await _remote.checkIn(zone: zone.name)),
    );
  }

  @override
  Future<Result<AttendanceToday>> checkOut(PunchZone zone) {
    return guardRequest(
      () async =>
          attendanceTodayFromResource(await _remote.checkOut(zone: zone.name)),
    );
  }
}
