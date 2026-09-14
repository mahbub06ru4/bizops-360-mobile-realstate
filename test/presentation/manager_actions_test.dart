import 'package:bizops360_mobile/data/repositories/fake_expense_repository.dart';
import 'package:bizops360_mobile/data/repositories/fake_task_repository.dart';
import 'package:bizops360_mobile/domain/entities/task_item.dart';
import 'package:bizops360_mobile/presentation/expenses/controllers/expense_approvals_controller.dart';
import 'package:bizops360_mobile/presentation/tasks/controllers/tasks_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TasksController.create adds an open task', () async {
    final c = TasksController(FakeTaskRepository());
    await c.load();
    final before = c.state.value.valueOrNull!.length;

    final ok = await c.create(
      title: 'Chase airline refund',
      priority: TaskPriority.high,
      assigneeName: 'Rahim',
    );
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(ok, isTrue);
    final list = c.state.value.valueOrNull!;
    expect(list.length, before + 1);
    expect(list.first.status, TaskStatus.open);
    expect(list.first.assigneeName, 'Rahim');
  });

  test('ExpenseApprovalsController.decide clears the row', () async {
    final c = ExpenseApprovalsController(FakeExpenseRepository());
    await c.load();
    final first = c.pending.value.valueOrNull!.first;

    await c.decide(first.id, approve: false);

    expect(c.pending.value.valueOrNull!.any((e) => e.id == first.id), isFalse);
  });
}
