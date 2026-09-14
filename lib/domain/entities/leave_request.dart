import 'package:equatable/equatable.dart';

enum LeaveType { casual, sick, annual, unpaid }

enum LeaveStatus { pending, approved, rejected, cancelled }

class LeaveRequest extends Equatable {
  const LeaveRequest({
    required this.id,
    required this.type,
    required this.from,
    required this.to,
    required this.status,
    required this.reason,
    this.decisionNote,
    this.requesterName,
  });

  final String id;
  final LeaveType type;
  final DateTime from;
  final DateTime to;
  final LeaveStatus status;
  final String reason;
  final String? decisionNote;

  /// Set on requests a manager sees; null for the user's own list.
  final String? requesterName;

  int get days => to.difference(from).inDays + 1;

  @override
  List<Object?> get props => [
    id,
    type,
    from,
    to,
    status,
    reason,
    decisionNote,
    requesterName,
  ];
}

/// Remaining balance for one leave type.
class LeaveBalance extends Equatable {
  const LeaveBalance({
    required this.type,
    required this.entitled,
    required this.taken,
  });

  final LeaveType type;
  final int entitled;
  final int taken;

  int get remaining => entitled - taken;

  @override
  List<Object?> get props => [type, entitled, taken];
}
