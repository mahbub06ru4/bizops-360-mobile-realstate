import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/leave_request.dart';
import '../../../domain/repositories/leave_repository.dart';

class ApprovalsController extends GetxController {
  ApprovalsController(this._repo);

  final LeaveRepository _repo;

  final Rx<AsyncValue<List<LeaveRequest>>> pending =
      const AsyncValue<List<LeaveRequest>>.loading().obs;
  final RxnString actingOn = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    pending.value = const AsyncValue.loading();
    pending.value = (await _repo.pendingApprovals()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  Future<void> decide(String id, {required bool approve, String? note}) async {
    actingOn.value = id;
    final result = await _repo.decide(id: id, approve: approve, note: note);
    actingOn.value = null;
    result.fold((_) {
      final current = pending.value.valueOrNull ?? const [];
      pending.value = AsyncValue.data(
        current.where((r) => r.id != id).toList(),
      );
    }, (_) {});
  }
}
