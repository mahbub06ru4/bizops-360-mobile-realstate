import '../../core/error/result.dart';
import '../entities/leave_request.dart';

abstract interface class LeaveRepository {
  Future<Result<List<LeaveBalance>>> balances();

  /// The current user's own requests, newest first.
  Future<Result<List<LeaveRequest>>> myRequests();

  Future<Result<LeaveRequest>> submit({
    required LeaveType type,
    required DateTime from,
    required DateTime to,
    required String reason,
  });

  /// Requests awaiting the current user's approval (manager view).
  Future<Result<List<LeaveRequest>>> pendingApprovals();

  Future<Result<LeaveRequest>> decide({
    required String id,
    required bool approve,
    String? note,
  });
}
