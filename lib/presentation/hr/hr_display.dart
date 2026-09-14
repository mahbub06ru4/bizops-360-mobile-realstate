import '../../core/localization/translation_keys.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/leave_request.dart';

extension AttendanceStatusDisplay on AttendanceStatus {
  String get labelKey => switch (this) {
    AttendanceStatus.present => Tr.attStatusPresent,
    AttendanceStatus.late => Tr.attStatusLate,
    AttendanceStatus.earlyLeave => Tr.attStatusEarly,
    AttendanceStatus.absent => Tr.attStatusAbsent,
    AttendanceStatus.onLeave => Tr.attStatusLeave,
    AttendanceStatus.holiday => Tr.attStatusHoliday,
  };

  ChipTone get tone => switch (this) {
    AttendanceStatus.present => ChipTone.brand,
    AttendanceStatus.late => ChipTone.signal,
    AttendanceStatus.earlyLeave => ChipTone.signal,
    AttendanceStatus.absent => ChipTone.critical,
    AttendanceStatus.onLeave => ChipTone.info,
    AttendanceStatus.holiday => ChipTone.neutral,
  };
}

extension LeaveTypeDisplay on LeaveType {
  String get labelKey => switch (this) {
    LeaveType.casual => Tr.leaveTypeCasual,
    LeaveType.sick => Tr.leaveTypeSick,
    LeaveType.annual => Tr.leaveTypeAnnual,
    LeaveType.unpaid => Tr.leaveTypeUnpaid,
  };
}

extension LeaveStatusDisplay on LeaveStatus {
  String get labelKey => switch (this) {
    LeaveStatus.pending => Tr.leaveStatusPending,
    LeaveStatus.approved => Tr.leaveStatusApproved,
    LeaveStatus.rejected => Tr.leaveStatusRejected,
    LeaveStatus.cancelled => Tr.leaveStatusCancelled,
  };

  ChipTone get tone => switch (this) {
    LeaveStatus.pending => ChipTone.signal,
    LeaveStatus.approved => ChipTone.brand,
    LeaveStatus.rejected => ChipTone.critical,
    LeaveStatus.cancelled => ChipTone.neutral,
  };
}
