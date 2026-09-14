import 'package:equatable/equatable.dart';

enum EmploymentStatus { active, onLeave, inactive }

/// A read-only directory entry — company setup (creating/editing an employee,
/// department or designation) is a Filament (web admin) concern, out of the
/// field app's scope. This is "who's on the team", not org configuration.
class Employee extends Equatable {
  const Employee({
    required this.id,
    required this.name,
    required this.status,
    this.designation,
    this.department,
    this.phone,
    this.email,
  });

  final String id;
  final String name;
  final EmploymentStatus status;
  final String? designation;
  final String? department;
  final String? phone;
  final String? email;

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    designation,
    department,
    phone,
    email,
  ];
}
