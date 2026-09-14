import 'package:bizops360_mobile/data/repositories/fake_task_repository.dart';
import 'package:bizops360_mobile/domain/entities/task_item.dart';
import 'package:bizops360_mobile/presentation/tasks/controllers/tasks_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TasksController controller;

  setUp(() => controller = TasksController(FakeTaskRepository()));

  test('buckets partition the open tasks with no overlap', () async {
    await controller.load();

    final today = controller.bucket(TaskBucket.today);
    final overdue = controller.bucket(TaskBucket.overdue);
    final upcoming = controller.bucket(TaskBucket.upcoming);

    for (final t in [...today, ...overdue, ...upcoming]) {
      expect(t.isDone, isFalse);
    }
    final ids = {
      ...today.map((t) => t.id),
      ...overdue.map((t) => t.id),
      ...upcoming.map((t) => t.id),
    };
    expect(ids.length, today.length + overdue.length + upcoming.length);
    expect(overdue.every((t) => t.isOverdue), isTrue);
  });

  test('setStatus to done removes the task from every open bucket', () async {
    await controller.load();
    final target = controller.bucket(TaskBucket.overdue).first;

    await controller.setStatus(target.id, TaskStatus.done);

    final stillListed = [
      ...controller.bucket(TaskBucket.today),
      ...controller.bucket(TaskBucket.overdue),
      ...controller.bucket(TaskBucket.upcoming),
    ].any((t) => t.id == target.id);
    expect(stillListed, isFalse);
  });
}
