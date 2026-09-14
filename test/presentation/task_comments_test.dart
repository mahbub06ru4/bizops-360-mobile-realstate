import 'package:bizops360_mobile/data/repositories/fake_task_repository.dart';
import 'package:bizops360_mobile/presentation/tasks/controllers/task_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads the seeded thread for a task that has comments', () async {
    final c = TaskDetailController(FakeTaskRepository(), 't1');
    await c.loadComments();

    expect(c.comments.value.valueOrNull, hasLength(2));
  });

  test('a task with no comments yet starts with an empty thread', () async {
    final c = TaskDetailController(FakeTaskRepository(), 't2');
    await c.loadComments();

    expect(c.comments.value.valueOrNull, isEmpty);
  });

  test(
    'addComment appends to the thread and clears the sending flag',
    () async {
      final c = TaskDetailController(FakeTaskRepository(), 't2');
      await c.loadComments();

      await c.addComment('On it.');

      expect(c.sendingComment.value, isFalse);
      final list = c.comments.value.valueOrNull!;
      expect(list, hasLength(1));
      expect(list.last.body, 'On it.');
      expect(list.last.author, 'You');
    },
  );

  test('a blank comment is ignored', () async {
    final c = TaskDetailController(FakeTaskRepository(), 't2');
    await c.loadComments();

    await c.addComment('   ');

    expect(c.comments.value.valueOrNull, isEmpty);
  });
}
