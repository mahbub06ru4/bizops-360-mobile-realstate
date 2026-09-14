import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/repositories/leave_repository.dart';

/// In-memory leave data for UI-first development (`Env.useFakeData`).
class FakeLeaveRepository implements LeaveRepository {
  FakeLeaveRepository() : _mine = _seedMine(), _pending = _seedPending();

  List<LeaveRequest> _mine;
  List<LeaveRequest> _pending;
  var _nextId = 100;

  static DateTime _day(int offset) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day).add(Duration(days: offset));
  }

  static List<LeaveRequest> _seedMine() => [
    LeaveRequest(
      id: '1',
      type: LeaveType.casual,
      from: _day(6),
      to: _day(7),
      status: LeaveStatus.pending,
      reason: 'Family event out of town.',
    ),
    LeaveRequest(
      id: '2',
      type: LeaveType.sick,
      from: _day(-10),
      to: _day(-10),
      status: LeaveStatus.approved,
      reason: 'Fever.',
      decisionNote: 'Get well soon.',
    ),
    LeaveRequest(
      id: '3',
      type: LeaveType.annual,
      from: _day(-40),
      to: _day(-36),
      status: LeaveStatus.rejected,
      reason: 'Trip.',
      decisionNote: 'Peak season — please replan.',
    ),
  ];

  static List<LeaveRequest> _seedPending() => [
    LeaveRequest(
      id: '51',
      type: LeaveType.casual,
      from: _day(2),
      to: _day(3),
      status: LeaveStatus.pending,
      reason: 'Personal work.',
      requesterName: 'Rahim Uddin',
    ),
    LeaveRequest(
      id: '52',
      type: LeaveType.sick,
      from: _day(1),
      to: _day(1),
      status: LeaveStatus.pending,
      reason: 'Doctor appointment.',
      requesterName: 'Sadia Islam',
    ),
  ];

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 300), () => value);

  @override
  Future<Result<List<LeaveBalance>>> balances() => _delayed(
    const Result.ok([
      LeaveBalance(type: LeaveType.casual, entitled: 10, taken: 4),
      LeaveBalance(type: LeaveType.sick, entitled: 14, taken: 3),
      LeaveBalance(type: LeaveType.annual, entitled: 20, taken: 12),
    ]),
  );

  @override
  Future<Result<List<LeaveRequest>>> myRequests() =>
      _delayed(Result.ok(List.unmodifiable(_mine)));

  @override
  Future<Result<LeaveRequest>> submit({
    required LeaveType type,
    required DateTime from,
    required DateTime to,
    required String reason,
  }) {
    final req = LeaveRequest(
      id: '${_nextId++}',
      type: type,
      from: from,
      to: to,
      status: LeaveStatus.pending,
      reason: reason,
    );
    _mine = [req, ..._mine];
    return _delayed(Result.ok(req));
  }

  @override
  Future<Result<List<LeaveRequest>>> pendingApprovals() =>
      _delayed(Result.ok(List.unmodifiable(_pending)));

  @override
  Future<Result<LeaveRequest>> decide({
    required String id,
    required bool approve,
    String? note,
  }) {
    LeaveRequest? decided;
    _pending = [
      for (final r in _pending)
        if (r.id == id)
          decided = LeaveRequest(
            id: r.id,
            type: r.type,
            from: r.from,
            to: r.to,
            status: approve ? LeaveStatus.approved : LeaveStatus.rejected,
            reason: r.reason,
            decisionNote: note,
            requesterName: r.requesterName,
          )
        else
          r,
    ]..removeWhere((r) => r.id == id);
    final result = decided;
    return _delayed(
      result == null ? const Result.err(NotFoundFailure()) : Result.ok(result),
    );
  }
}
