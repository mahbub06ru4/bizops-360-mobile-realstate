import 'package:equatable/equatable.dart';

import 'employee.dart';

/// Mirrors `TeamResource`.
class Team extends Equatable {
  const Team({
    required this.id,
    required this.name,
    this.description,
    this.leadEmployeeId,
    this.membersCount = 0,
    this.members = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String? leadEmployeeId;
  final int membersCount;
  final List<Employee> members;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    leadEmployeeId,
    membersCount,
    members,
  ];
}

class TeamInput extends Equatable {
  const TeamInput({required this.name, this.description, this.leadEmployeeId});

  final String name;
  final String? description;
  final String? leadEmployeeId;

  @override
  List<Object?> get props => [name, description, leadEmployeeId];
}
