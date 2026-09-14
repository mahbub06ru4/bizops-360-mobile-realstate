import 'package:equatable/equatable.dart';

class TaskSubtask extends Equatable {
  const TaskSubtask({
    required this.id,
    required this.title,
    required this.done,
  });

  final String id;
  final String title;
  final bool done;

  TaskSubtask copyWith({bool? done}) =>
      TaskSubtask(id: id, title: title, done: done ?? this.done);

  @override
  List<Object?> get props => [id, title, done];
}
