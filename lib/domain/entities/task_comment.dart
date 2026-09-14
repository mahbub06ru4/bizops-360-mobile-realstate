import 'package:equatable/equatable.dart';

class TaskComment extends Equatable {
  const TaskComment({
    required this.id,
    required this.author,
    required this.body,
    required this.at,
  });

  final String id;
  final String author;
  final String body;
  final DateTime at;

  @override
  List<Object?> get props => [id, author, body, at];
}
