import 'dart:math';

import '../../core/error/result.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';

/// In-memory attendance for UI-first development (`Env.useFakeData`).
class FakeAttendanceRepository implements AttendanceRepository {
  AttendanceToday _today = const AttendanceToday();

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 300), () => value);

  @override
  Future<Result<AttendanceToday>> today() => _delayed(Result.ok(_today));

  @override
  Future<Result<AttendanceToday>> checkIn(PunchZone zone) {
    _today = AttendanceToday(checkIn: DateTime.now(), checkInZone: zone);
    return _delayed(Result.ok(_today));
  }

  @override
  Future<Result<AttendanceToday>> checkOut(PunchZone zone) {
    _today = _today.copyWith(checkOut: DateTime.now(), checkOutZone: zone);
    return _delayed(Result.ok(_today));
  }

  @override
  Future<Result<List<AttendanceDay>>> history() {
    final rnd = Random(7);
    final today = DateTime.now();
    final days = <AttendanceDay>[];
    for (var i = 1; i <= 21; i++) {
      final date = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: i));
      if (date.weekday == DateTime.friday) {
        days.add(AttendanceDay(date: date, status: AttendanceStatus.holiday));
        continue;
      }
      final roll = rnd.nextInt(10);
      final status = switch (roll) {
        0 => AttendanceStatus.onLeave,
        1 => AttendanceStatus.late,
        2 => AttendanceStatus.earlyLeave,
        _ => AttendanceStatus.present,
      };
      final inH = status == AttendanceStatus.late ? 10 : 9;
      final zone = rnd.nextInt(6) == 0 ? PunchZone.outside : PunchZone.office;
      days.add(
        AttendanceDay(
          date: date,
          status: status,
          checkIn: status == AttendanceStatus.onLeave
              ? null
              : DateTime(date.year, date.month, date.day, inH, 12),
          checkOut: status == AttendanceStatus.onLeave
              ? null
              : DateTime(
                  date.year,
                  date.month,
                  date.day,
                  status == AttendanceStatus.earlyLeave ? 15 : 18,
                  5,
                ),
          checkInZone: status == AttendanceStatus.onLeave ? null : zone,
          checkOutZone: status == AttendanceStatus.onLeave ? null : zone,
        ),
      );
    }
    return _delayed(Result.ok(days));
  }
}
