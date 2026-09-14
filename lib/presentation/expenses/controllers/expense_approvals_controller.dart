import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/repositories/expense_repository.dart';

class ExpenseApprovalsController extends GetxController {
  ExpenseApprovalsController(this._repo);

  final ExpenseRepository _repo;

  final Rx<AsyncValue<List<Expense>>> pending =
      const AsyncValue<List<Expense>>.loading().obs;
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

  Future<void> decide(String id, {required bool approve}) async {
    actingOn.value = id;
    final result = await _repo.decide(id: id, approve: approve);
    actingOn.value = null;
    result.fold((_) {
      final current = pending.value.valueOrNull ?? const [];
      pending.value = AsyncValue.data(
        current.where((e) => e.id != id).toList(),
      );
    }, (_) {});
  }
}
