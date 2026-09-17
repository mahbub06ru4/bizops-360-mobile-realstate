import 'package:equatable/equatable.dart';

/// Mirrors `DesignationResource`.
class Designation extends Equatable {
  const Designation({
    required this.id,
    required this.title,
    this.departmentId,
    this.departmentName,
    this.rank,
  });

  final String id;
  final String title;
  final String? departmentId;
  final String? departmentName;
  final int? rank;

  @override
  List<Object?> get props => [id, title, departmentId, departmentName, rank];
}

class DesignationInput extends Equatable {
  const DesignationInput({required this.title, this.departmentId, this.rank});

  final String title;
  final String? departmentId;
  final int? rank;

  @override
  List<Object?> get props => [title, departmentId, rank];
}
