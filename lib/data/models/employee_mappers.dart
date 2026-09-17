import '../../domain/entities/employee.dart';

/// `EmployeeResource` ↔ [Employee]. Verified against
/// `app/Modules/Organization/Http/Resources/EmployeeResource.php` and
/// `App\Modules\Organization\Domain\EmploymentStatus`: status is
/// `employment_status` (`active`, `probation`, `on_leave`, `terminated`), and
/// nested `designation` uses `title` (not `name`); `department`/`branch` use
/// `name`. There is no salary or emergency-contact field on the model.
const Map<String, EmploymentStatus> _statusFromApi = {
  'active': EmploymentStatus.active,
  'probation': EmploymentStatus.probation,
  'on_leave': EmploymentStatus.onLeave,
  'terminated': EmploymentStatus.terminated,
};

const Map<EmploymentStatus, String> _statusToApi = {
  EmploymentStatus.active: 'active',
  EmploymentStatus.probation: 'probation',
  EmploymentStatus.onLeave: 'on_leave',
  EmploymentStatus.terminated: 'terminated',
};

String employmentStatusToApi(EmploymentStatus status) =>
    _statusToApi[status] ?? 'active';

Employee employeeFromJson(Map<String, dynamic> json) {
  final branch = json['branch'];
  final department = json['department'];
  final designation = json['designation'];
  final firstName = json['first_name'] as String? ?? '';
  final lastName = json['last_name'] as String? ?? '';

  return Employee(
    id: json['id'].toString(),
    employeeCode: json['employee_code'] as String? ?? '',
    firstName: firstName,
    lastName: lastName,
    name: json['full_name'] as String? ?? '$firstName $lastName'.trim(),
    status:
        _statusFromApi[json['employment_status']] ?? EmploymentStatus.active,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    hireDate: json['hire_date'] is String
        ? DateTime.tryParse(json['hire_date'] as String)
        : null,
    userId: json['user_id']?.toString(),
    branchId: json['branch_id']?.toString(),
    departmentId: json['department_id']?.toString(),
    designationId: json['designation_id']?.toString(),
    branchName: branch is Map ? branch['name'] as String? : null,
    departmentName: department is Map ? department['name'] as String? : null,
    designationName: designation is Map
        ? designation['title'] as String?
        : null,
  );
}

Map<String, dynamic> employeeInputToJson(EmployeeInput input) => {
  'employee_code': input.employeeCode,
  'first_name': input.firstName,
  'last_name': input.lastName,
  'hire_date':
      '${input.hireDate.year.toString().padLeft(4, '0')}-'
      '${input.hireDate.month.toString().padLeft(2, '0')}-'
      '${input.hireDate.day.toString().padLeft(2, '0')}',
  if (input.email != null) 'email': input.email,
  if (input.phone != null) 'phone': input.phone,
  if (input.userId != null) 'user_id': int.tryParse(input.userId!),
  if (input.branchId != null) 'branch_id': int.tryParse(input.branchId!),
  if (input.departmentId != null)
    'department_id': int.tryParse(input.departmentId!),
  if (input.designationId != null)
    'designation_id': int.tryParse(input.designationId!),
  if (input.employmentStatus != null)
    'employment_status': employmentStatusToApi(input.employmentStatus!),
};
