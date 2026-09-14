import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/repositories/expense_repository.dart';

class ExpensesController extends GetxController {
  ExpensesController(this._repo);

  final ExpenseRepository _repo;

  final Rx<AsyncValue<List<Expense>>> state =
      const AsyncValue<List<Expense>>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.mine()).fold(AsyncValue.data, AsyncValue.error);
  }

  num get pendingTotal => (state.value.valueOrNull ?? const [])
      .where((e) => e.status == ExpenseStatus.pending)
      .fold<num>(0, (sum, e) => sum + e.amount);

  Future<bool> submit({
    required ExpenseCategory category,
    required num amount,
    required DateTime date,
    String? note,
    bool hasReceipt = false,
  }) async {
    final result = await _repo.submit(
      category: category,
      amount: amount,
      date: date,
      note: note,
      hasReceipt: hasReceipt,
    );
    return result.fold((_) {
      load();
      return true;
    }, (_) => false);
  }
}
