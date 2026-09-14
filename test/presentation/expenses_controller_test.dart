import 'package:bizops360_mobile/data/repositories/fake_expense_repository.dart';
import 'package:bizops360_mobile/domain/entities/expense.dart';
import 'package:bizops360_mobile/presentation/expenses/controllers/expenses_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'submit prepends a pending expense and updates the pending total',
    () async {
      final c = ExpensesController(FakeExpenseRepository());
      await c.load();
      final beforeTotal = c.pendingTotal;

      final ok = await c.submit(
        category: ExpenseCategory.meals,
        amount: 500,
        date: DateTime(2026, 9, 9),
        note: 'Client tea',
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(ok, isTrue);
      expect(c.state.value.valueOrNull!.first.status, ExpenseStatus.pending);
      expect(c.pendingTotal, beforeTotal + 500);
    },
  );
}
