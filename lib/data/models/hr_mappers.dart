import '../../domain/entities/attendance.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/entities/office_location.dart';

// Attendance ----------------------------------------------------------------

const Map<String, AttendanceStatus> _attStatusFromApi = {
  'present': AttendanceStatus.present,
  'late': AttendanceStatus.late,
  'early_leave': AttendanceStatus.earlyLeave,
  'half_day': AttendanceStatus.earlyLeave,
  'absent': AttendanceStatus.absent,
  'on_leave': AttendanceStatus.onLeave,
  'leave': AttendanceStatus.onLeave,
  'holiday': AttendanceStatus.holiday,
};

DateTime? _ts(dynamic v) => DateTime.tryParse(v?.toString() ?? '');

PunchZone? _zone(dynamic v) => switch (v?.toString()) {
  'office' => PunchZone.office,
  'outside' => PunchZone.outside,
  _ => null,
};

AttendanceDay attendanceDayFromJson(Map<String, dynamic> json) {
  return AttendanceDay(
    date: _ts(json['date']) ?? DateTime.now(),
    status: _attStatusFromApi[json['status']] ?? AttendanceStatus.present,
    checkIn: _ts(json['check_in_at']),
    checkOut: _ts(json['check_out_at']),
    checkInZone: _zone(json['check_in_zone']),
    checkOutZone: _zone(json['check_out_zone']),
  );
}

/// Today's card from the attendance list — the row whose `date` is today.
AttendanceToday attendanceTodayFrom(List<Map<String, dynamic>> rows) {
  final now = DateTime.now();
  for (final r in rows) {
    final d = _ts(r['date']);
    if (d != null &&
        d.year == now.year &&
        d.month == now.month &&
        d.day == now.day) {
      return AttendanceToday(
        checkIn: _ts(r['check_in_at']),
        checkOut: _ts(r['check_out_at']),
        checkInZone: _zone(r['check_in_zone']),
        checkOutZone: _zone(r['check_out_zone']),
      );
    }
  }
  return const AttendanceToday();
}

AttendanceToday attendanceTodayFromResource(Map<String, dynamic> json) {
  return AttendanceToday(
    checkIn: _ts(json['check_in_at']),
    checkOut: _ts(json['check_out_at']),
    checkInZone: _zone(json['check_in_zone']),
    checkOutZone: _zone(json['check_out_zone']),
  );
}

// Office location -----------------------------------------------------------

OfficeLocation officeLocationFromJson(Map<String, dynamic> json) {
  return OfficeLocation(
    label: json['label'] as String? ?? '',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    radiusMeters: (json['radius_meters'] as num?)?.toDouble() ?? 500,
    startTime: json['start_time'] as String? ?? '10:00',
    endTime: json['end_time'] as String? ?? '18:00',
  );
}

Map<String, dynamic> officeLocationToJson(OfficeLocation o) => {
  'label': o.label,
  'latitude': o.latitude,
  'longitude': o.longitude,
  'radius_meters': o.radiusMeters,
  'start_time': o.startTime,
  'end_time': o.endTime,
};

// Leave -------------------------------------------------------------------

const Map<String, LeaveStatus> _leaveStatusFromApi = {
  'pending': LeaveStatus.pending,
  'approved': LeaveStatus.approved,
  'rejected': LeaveStatus.rejected,
  'cancelled': LeaveStatus.cancelled,
};

/// The backend keys leave on a tenant-defined `leave_type_id`; the app's fixed
/// enum is a best-effort match on the loaded type's `code` / `name`.
LeaveType leaveTypeFromCode(String? code) {
  final c = (code ?? '').toLowerCase();
  if (c.contains('sick')) return LeaveType.sick;
  if (c.contains('annual') || c.contains('earned')) return LeaveType.annual;
  if (c.contains('unpaid') || c.contains('lop')) return LeaveType.unpaid;
  return LeaveType.casual;
}

LeaveRequest leaveRequestFromJson(Map<String, dynamic> json) {
  final leaveType = json['leave_type'];
  final employee = json['employee'];
  final code = leaveType is Map
      ? (leaveType['code'] ?? leaveType['name']) as String?
      : null;

  return LeaveRequest(
    id: json['id'].toString(),
    type: leaveTypeFromCode(code),
    from: _ts(json['start_date']) ?? DateTime.now(),
    to: _ts(json['end_date']) ?? DateTime.now(),
    status: _leaveStatusFromApi[json['status']] ?? LeaveStatus.pending,
    reason: json['reason'] as String? ?? '',
    decisionNote: json['decision_note'] as String?,
    requesterName: employee is Map ? employee['name'] as String? : null,
  );
}

LeaveBalance leaveBalanceFromJson(Map<String, dynamic> json) {
  final leaveType = json['leave_type'];
  final code = leaveType is Map
      ? (leaveType['code'] ?? leaveType['name']) as String?
      : null;
  return LeaveBalance(
    type: leaveTypeFromCode(code),
    entitled: (json['entitled_days'] as num?)?.toInt() ?? 0,
    taken: (json['used_days'] as num?)?.toInt() ?? 0,
  );
}
