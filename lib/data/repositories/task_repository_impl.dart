import '../../core/error/result.dart';
import '../../domain/entities/task_comment.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_mappers.dart';
import 'remote_guard.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._remote);

  final TaskRemoteDataSource _remote;

  @override
  Future<Result<List<TaskItem>>> myTasks() {
    return guardRequest(
      () async =>
          (await _remote.list()).map(taskFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<TaskItem>> byId(String id) {
    return guardRequest(() async => taskFromJson(await _remote.byId(id)));
  }

  @override
  Future<Result<TaskItem>> updateStatus(String id, TaskStatus status) {
    return guardRequest(
      () async => taskFromJson(
        await _remote.changeStatus(id, statusToApi[status] ?? 'todo'),
      ),
    );
  }

  @override
  Future<Result<TaskItem>> create({
    required String title,
    required TaskPriority priority,
    DateTime? dueDate,
    String? assigneeName,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        'title': title,
        'priority': priorityToApi[priority] ?? 'normal',
        if (dueDate != null) 'due_at': dueDate.toIso8601String(),
      };
      return taskFromJson(await _remote.create(body));
    });
  }

  @override
  Future<Result<TaskItem>> updateSubtaskStatus(
    String taskId,
    String subtaskId,
    bool done,
  ) {
    return guardRequest(() async {
      await _remote.changeStatus(subtaskId, done ? 'done' : 'todo');
      return taskFromJson(await _remote.byId(taskId));
    });
  }

  @override
  Future<Result<List<TaskComment>>> comments(String taskId) {
    return guardRequest(
      () async => (await _remote.comments(
        taskId,
      )).map(taskCommentFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<TaskComment>> addComment(String taskId, String body) {
    return guardRequest(
      () async => taskCommentFromJson(await _remote.addComment(taskId, body)),
    );
  }
}
