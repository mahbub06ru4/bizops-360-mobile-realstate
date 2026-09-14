import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/task_comment.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/entities/task_subtask.dart';
import '../../domain/repositories/task_repository.dart';

/// In-memory tasks for UI-first development (`Env.useFakeData`).
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository() : _items = _seed();

  List<TaskItem> _items;

  static DateTime _day(int offset) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day).add(Duration(days: offset));
  }

  static List<TaskItem> _seed() => [
    TaskItem(
      id: 't1',
      title: 'Collect passports — Karim family',
      description: 'Four passports for the Schengen application. Front desk.',
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      dueDate: _day(0),
      assigneeName: 'You',
      subtasksTotal: 4,
      subtasksDone: 2,
      commentCount: 3,
      subtasks: const [
        TaskSubtask(id: 'st1', title: 'Passport — father', done: true),
        TaskSubtask(id: 'st2', title: 'Passport — mother', done: true),
        TaskSubtask(id: 'st3', title: 'Passport — son', done: false),
        TaskSubtask(id: 'st4', title: 'Passport — daughter', done: false),
      ],
    ),
    TaskItem(
      id: 't2',
      title: 'Send Dubai package quote to Nusrat',
      status: TaskStatus.open,
      priority: TaskPriority.urgent,
      dueDate: _day(-1),
      assigneeName: 'You',
      commentCount: 1,
    ),
    TaskItem(
      id: 't3',
      title: 'Confirm hotel block — Bali group (12 pax)',
      status: TaskStatus.blocked,
      priority: TaskPriority.normal,
      dueDate: _day(1),
      assigneeName: 'You',
      subtasksTotal: 3,
      subtasksDone: 1,
    ),
    TaskItem(
      id: 't4',
      title: 'Review invoice #2043 before it goes out',
      status: TaskStatus.open,
      priority: TaskPriority.normal,
      dueDate: _day(3),
      assigneeName: 'You',
    ),
    TaskItem(
      id: 't5',
      title: 'File visa outcome — Rahman honeymoon',
      status: TaskStatus.done,
      priority: TaskPriority.low,
      dueDate: _day(-2),
      assigneeName: 'You',
    ),
  ];

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 350), () => value);

  @override
  Future<Result<List<TaskItem>>> myTasks() =>
      _delayed(Result.ok(List.unmodifiable(_items)));

  @override
  Future<Result<TaskItem>> byId(String id) {
    final match = _items.where((t) => t.id == id).firstOrNull;
    return _delayed(
      match == null ? const Result.err(NotFoundFailure()) : Result.ok(match),
    );
  }

  @override
  Future<Result<TaskItem>> updateStatus(String id, TaskStatus status) {
    TaskItem? updated;
    _items = [
      for (final t in _items)
        if (t.id == id) updated = t.copyWith(status: status) else t,
    ];
    final result = updated;
    return _delayed(
      result == null ? const Result.err(NotFoundFailure()) : Result.ok(result),
    );
  }

  @override
  Future<Result<TaskItem>> updateSubtaskStatus(
    String taskId,
    String subtaskId,
    bool done,
  ) {
    final index = _items.indexWhere((t) => t.id == taskId);
    if (index == -1) {
      return _delayed(const Result.err(NotFoundFailure()));
    }
    final task = _items[index];
    final updated = task.copyWith(
      subtasks: [
        for (final s in task.subtasks)
          if (s.id == subtaskId) s.copyWith(done: done) else s,
      ],
    );
    _items = [..._items]..[index] = updated;
    return _delayed(Result.ok(updated));
  }

  var _nextId = 90;

  @override
  Future<Result<TaskItem>> create({
    required String title,
    required TaskPriority priority,
    DateTime? dueDate,
    String? assigneeName,
  }) {
    final task = TaskItem(
      id: 't${_nextId++}',
      title: title,
      status: TaskStatus.open,
      priority: priority,
      dueDate: dueDate,
      assigneeName: assigneeName ?? 'You',
    );
    _items = [task, ..._items];
    return _delayed(Result.ok(task));
  }

  final Map<String, List<TaskComment>> _comments = {
    't1': [
      TaskComment(
        id: 'c1',
        author: 'Nadia',
        body: 'Father and mother collected today.',
        at: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TaskComment(
        id: 'c2',
        author: 'You',
        body: "Chasing the kids' passports tomorrow.",
        at: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  };
  var _nextCommentId = 90;

  @override
  Future<Result<List<TaskComment>>> comments(String taskId) =>
      _delayed(Result.ok(List.unmodifiable(_comments[taskId] ?? const [])));

  @override
  Future<Result<TaskComment>> addComment(String taskId, String body) {
    final comment = TaskComment(
      id: 'c${_nextCommentId++}',
      author: 'You',
      body: body,
      at: DateTime.now(),
    );
    _comments.update(
      taskId,
      (list) => [...list, comment],
      ifAbsent: () => [comment],
    );
    return _delayed(Result.ok(comment));
  }
}
