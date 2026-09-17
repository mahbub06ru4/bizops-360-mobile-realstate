import 'package:equatable/equatable.dart';

/// Mirrors `App\Modules\Organization\Domain\EmploymentStatus` exactly
/// (`active`, `probation`, `on_leave`, `terminated`) — see
/// `data/models/employee_mappers.dart` for the wire mapping.
enum EmploymentStatus { active, probation, onLeave, terminated }

/// A team directory entry — the full `EmployeeResource` shape, so the app can
/// show a profile and support create/edit/terminate, not just a read-only row.
class Employee extends Equatable {
  const Employee({
    required this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.status,
    this.email,
    this.phone,
    this.hireDate,
    this.userId,
    this.branchId,
    this.departmentId,
    this.designationId,
    this.branchName,
    this.departmentName,
    this.designationName,
  });

  final String id;
  final String employeeCode;
  final String firstName;
  final String lastName;

  /// `full_name` from the API.
  final String name;
  final EmploymentStatus status;
  final String? email;
  final String? phone;
  final DateTime? hireDate;
  final String? userId;
  final String? branchId;
  final String? departmentId;
  final String? designationId;

  /// Denormalised for list/detail display when the resource embeds the
  /// relation. `designation` still means "job title" here.
  final String? branchName;
  final String? departmentName;
  final String? designationName;

  /// Back-compat aliases used by the existing team list/search UI.
  String? get designation => designationName;
  String? get department => departmentName;

  Employee copyWith({
    String? branchId,
    String? departmentId,
    String? designationId,
    String? branchName,
    String? departmentName,
    String? designationName,
    EmploymentStatus? status,
  }) => Employee(
    id: id,
    employeeCode: employeeCode,
    firstName: firstName,
    lastName: lastName,
    name: name,
    status: status ?? this.status,
    email: email,
    phone: phone,
    hireDate: hireDate,
    userId: userId,
    branchId: branchId ?? this.branchId,
    departmentId: departmentId ?? this.departmentId,
    designationId: designationId ?? this.designationId,
    branchName: branchName ?? this.branchName,
    departmentName: departmentName ?? this.departmentName,
    designationName: designationName ?? this.designationName,
  );

  @override
  List<Object?> get props => [
    id,
    employeeCode,
    firstName,
    lastName,
    name,
    status,
    email,
    phone,
    hireDate,
    userId,
    branchId,
    departmentId,
    designationId,
    branchName,
    departmentName,
    designationName,
  ];
}

/// Input for creating/updating an employee — matches `EmployeeRequest`'s
/// validated fields exactly.
class EmployeeInput extends Equatable {
  const EmployeeInput({
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.hireDate,
    this.email,
    this.phone,
    this.userId,
    this.branchId,
    this.departmentId,
    this.designationId,
    this.employmentStatus,
  });

  final String employeeCode;
  final String firstName;
  final String lastName;
  final DateTime hireDate;
  final String? email;
  final String? phone;
  final String? userId;
  final String? branchId;
  final String? departmentId;
  final String? designationId;
  final EmploymentStatus? employmentStatus;

  @override
  List<Object?> get props => [
    employeeCode,
    firstName,
    lastName,
    hireDate,
    email,
    phone,
    userId,
    branchId,
    departmentId,
    designationId,
    employmentStatus,
  ];
}
