import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/task_item.dart';
import '../../../domain/repositories/task_repository.dart';

enum TaskBucket { today, overdue, upcoming }

class TasksController extends GetxController {
  TasksController(this._repo);

  final TaskRepository _repo;

  final Rx<AsyncValue<List<TaskItem>>> state =
      const AsyncValue<List<TaskItem>>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.myTasks()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  List<TaskItem> bucket(TaskBucket b) {
    final all = state.value.valueOrNull ?? const [];
    final open = all.where((t) => !t.isDone);
    return switch (b) {
      TaskBucket.overdue => open.where((t) => t.isOverdue).toList(),
      TaskBucket.today =>
        open.where((t) => t.isDueToday() && !t.isOverdue).toList(),
      TaskBucket.upcoming =>
        open.where((t) => !t.isOverdue && !t.isDueToday()).toList(),
    };
  }

  int countOf(TaskBucket b) => bucket(b).length;

  Future<bool> create({
    required String title,
    required TaskPriority priority,
    DateTime? dueDate,
    String? assigneeName,
  }) async {
    final result = await _repo.create(
      title: title,
      priority: priority,
      dueDate: dueDate,
      assigneeName: assigneeName,
    );
    return result.fold((_) {
      load();
      return true;
    }, (_) => false);
  }

  Future<void> setStatus(String id, TaskStatus status) async {
    final result = await _repo.updateStatus(id, status);
    final current = state.value.valueOrNull;
    if (current == null) return;
    result.fold((updated) {
      state.value = AsyncValue.data([
        for (final t in current)
          if (t.id == updated.id) updated else t,
      ]);
    }, (_) {});
  }
}
