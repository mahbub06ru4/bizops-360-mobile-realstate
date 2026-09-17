import 'package:equatable/equatable.dart';

/// Mirrors `DepartmentResource`.
class Department extends Equatable {
  const Department({
    required this.id,
    required this.name,
    required this.code,
    this.branchId,
    this.branchName,
    this.description,
  });

  final String id;
  final String name;
  final String code;
  final String? branchId;
  final String? branchName;
  final String? description;

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    branchId,
    branchName,
    description,
  ];
}

class DepartmentInput extends Equatable {
  const DepartmentInput({
    required this.name,
    required this.code,
    this.branchId,
    this.description,
  });

  final String name;
  final String code;
  final String? branchId;
  final String? description;

  @override
  List<Object?> get props => [name, code, branchId, description];
}
