import '../../domain/entities/task_comment.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/entities/task_subtask.dart';

/// `TaskResource` ↔ [TaskItem].
///
/// Backend `status` is `todo | in_progress | in_review | blocked | done |
/// cancelled`; the app's four-state model folds `in_review` into `inProgress`
/// and `cancelled` into `done` (both read as "closed" in the list).
const Map<String, TaskStatus> _statusFromApi = {
  'todo': TaskStatus.open,
  'in_progress': TaskStatus.inProgress,
  'in_review': TaskStatus.inProgress,
  'blocked': TaskStatus.blocked,
  'done': TaskStatus.done,
  'cancelled': TaskStatus.done,
};

const Map<TaskStatus, String> statusToApi = {
  TaskStatus.open: 'todo',
  TaskStatus.inProgress: 'in_progress',
  TaskStatus.blocked: 'blocked',
  TaskStatus.done: 'done',
};

const Map<String, TaskPriority> _priorityFromApi = {
  'low': TaskPriority.low,
  'normal': TaskPriority.normal,
  'high': TaskPriority.high,
  'urgent': TaskPriority.urgent,
};

const Map<TaskPriority, String> priorityToApi = {
  TaskPriority.low: 'low',
  TaskPriority.normal: 'normal',
  TaskPriority.high: 'high',
  TaskPriority.urgent: 'urgent',
};

TaskItem taskFromJson(Map<String, dynamic> json) {
  final assignee = json['assignee_employee'];
  final subtasksCount = json['subtasks_count'];
  final subtasks = json['subtasks'];
  final subtaskItems = subtasks is List
      ? subtasks
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (t) => TaskSubtask(
                id: t['id'].toString(),
                title: t['title'] as String? ?? '',
                done: t['status'] == 'done' || t['status'] == 'cancelled',
              ),
            )
            .toList(growable: false)
      : const <TaskSubtask>[];

  return TaskItem(
    id: json['id'].toString(),
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    status: _statusFromApi[json['status']] ?? TaskStatus.open,
    priority: _priorityFromApi[json['priority']] ?? TaskPriority.normal,
    dueDate: DateTime.tryParse(json['due_at'] as String? ?? ''),
    assigneeName: assignee is Map ? assignee['name'] as String? : null,
    subtasksTotal: subtasksCount is num
        ? subtasksCount.toInt()
        : (subtasks is List ? subtasks.length : 0),
    subtasksDone: subtasks is List
        ? subtasks
              .whereType<Map<dynamic, dynamic>>()
              .where((t) => t['status'] == 'done' || t['status'] == 'cancelled')
              .length
        : 0,
    subtasks: subtaskItems,
  );
}

TaskComment taskCommentFromJson(Map<String, dynamic> json) {
  final author = json['author'] ?? json['user'] ?? json['created_by'];
  return TaskComment(
    id: json['id'].toString(),
    author: author is Map ? author['name'] as String? ?? '' : '',
    body: json['body'] as String? ?? json['comment'] as String? ?? '',
    at:
        DateTime.tryParse(json['created_at']?.toString() ?? '') ??
        DateTime.now(),
  );
}
