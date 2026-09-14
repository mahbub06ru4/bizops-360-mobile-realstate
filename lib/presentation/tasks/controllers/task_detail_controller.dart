import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/task_comment.dart';
import '../../../domain/entities/task_item.dart';
import '../../../domain/repositories/task_repository.dart';

class TaskDetailController extends GetxController {
  TaskDetailController(this._repo, this._taskId, {TaskItem? seed})
    : state = Rx(seed == null ? const AsyncLoading() : AsyncData(seed));

  final TaskRepository _repo;
  final String _taskId;

  final Rx<AsyncValue<TaskItem>> state;
  final RxBool updating = false.obs;

  final Rx<AsyncValue<List<TaskComment>>> comments =
      const AsyncValue<List<TaskComment>>.loading().obs;
  final RxBool sendingComment = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (state.value is! AsyncData) reload();
    loadComments();
  }

  Future<void> reload() async {
    state.value = (await _repo.byId(
      _taskId,
    )).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<void> loadComments() async {
    comments.value = (await _repo.comments(
      _taskId,
    )).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<void> setStatus(TaskStatus status) async {
    updating.value = true;
    final result = await _repo.updateStatus(_taskId, status);
    updating.value = false;
    result.fold((t) => state.value = AsyncValue.data(t), (_) {});
  }

  void toggleDone() {
    final task = state.value.valueOrNull;
    if (task == null) return;
    setStatus(task.isDone ? TaskStatus.open : TaskStatus.done);
  }

  Future<void> toggleSubtask(String subtaskId, bool done) async {
    final task = state.value.valueOrNull;
    if (task == null) return;
    final result = await _repo.updateSubtaskStatus(_taskId, subtaskId, done);
    result.fold((t) => state.value = AsyncValue.data(t), (_) {});
  }

  Future<void> addComment(String body) async {
    if (body.trim().isEmpty || sendingComment.value) return;
    sendingComment.value = true;
    final result = await _repo.addComment(_taskId, body.trim());
    sendingComment.value = false;
    result.fold((comment) {
      final current = comments.value.valueOrNull ?? const [];
      comments.value = AsyncValue.data([...current, comment]);
    }, (_) {});
  }
}
