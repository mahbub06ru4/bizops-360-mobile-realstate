import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/repositories/leave_repository.dart';
import '../datasources/hr_remote_datasource.dart';
import '../models/hr_mappers.dart';
import 'remote_guard.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  LeaveRepositoryImpl(this._remote);

  final HrRemoteDataSource _remote;

  @override
  Future<Result<List<LeaveBalance>>> balances() {
    return guardRequest(
      () async => (await _remote.leaveBalances())
          .map(leaveBalanceFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<List<LeaveRequest>>> myRequests() {
    return guardRequest(
      () async => (await _remote.leaveRequests())
          .map(leaveRequestFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<List<LeaveRequest>>> pendingApprovals() {
    return guardRequest(
      () async => (await _remote.leaveRequests(
        status: 'pending',
      )).map(leaveRequestFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<LeaveRequest>> submit({
    required LeaveType type,
    required DateTime from,
    required DateTime to,
    required String reason,
  }) async {
    // The backend keys on a tenant-defined leave_type_id; match the app's enum
    // against the configured types by code/name.
    final typesResult = await guardRequest(_remote.leaveTypes);
    if (typesResult case Err(:final failure)) return Result.err(failure);
    final types = typesResult.valueOrNull ?? const [];
    if (types.isEmpty) {
      return const Result.err(
        ValidationFailure(
          'No leave types are configured for this company yet.',
          {},
        ),
      );
    }
    final match = types.firstWhere(
      (t) => leaveTypeFromCode((t['code'] ?? t['name']) as String?) == type,
      orElse: () => types.first,
    );

    return guardRequest(
      () async => leaveRequestFromJson(
        await _remote.submitLeave({
          'leave_type_id': match['id'],
          'start_date': from.toIso8601String().split('T').first,
          'end_date': to.toIso8601String().split('T').first,
          'reason': reason,
        }),
      ),
    );
  }

  @override
  Future<Result<LeaveRequest>> decide({
    required String id,
    required bool approve,
    String? note,
  }) {
    return guardRequest(
      () async => leaveRequestFromJson(
        await _remote.decideLeave(id, approve: approve, note: note),
      ),
    );
  }
}
