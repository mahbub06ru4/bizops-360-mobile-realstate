import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/leave_request.dart';
import '../../../domain/repositories/leave_repository.dart';

class LeaveController extends GetxController {
  LeaveController(this._repo);

  final LeaveRepository _repo;

  final Rx<AsyncValue<List<LeaveBalance>>> balances =
      const AsyncValue<List<LeaveBalance>>.loading().obs;
  final Rx<AsyncValue<List<LeaveRequest>>> requests =
      const AsyncValue<List<LeaveRequest>>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    balances.value = const AsyncValue.loading();
    requests.value = const AsyncValue.loading();
    balances.value = (await _repo.balances()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
    requests.value = (await _repo.myRequests()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  Future<bool> submit({
    required LeaveType type,
    required DateTime from,
    required DateTime to,
    required String reason,
  }) async {
    final result = await _repo.submit(
      type: type,
      from: from,
      to: to,
      reason: reason,
    );
    return result.fold((_) {
      load();
      return true;
    }, (_) => false);
  }
}
