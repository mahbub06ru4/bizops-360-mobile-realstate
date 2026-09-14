import '../../domain/entities/employee.dart';

/// `EmployeeResource` ↔ [Employee]. Verified against
/// `app/Modules/Organization/Http/Resources/EmployeeResource.php`: status is
/// `employment_status` (active, probation, on_leave, terminated), and nested
/// `designation` uses `title` (not `name`); `department` does use `name`.
const Map<String, EmploymentStatus> _statusFromApi = {
  'active': EmploymentStatus.active,
  'on_leave': EmploymentStatus.onLeave,
  'probation': EmploymentStatus.active,
  'inactive': EmploymentStatus.inactive,
  'terminated': EmploymentStatus.inactive,
};

Employee employeeFromJson(Map<String, dynamic> json) {
  final designation = json['designation'];
  final department = json['department'];

  return Employee(
    id: json['id'].toString(),
    name: json['full_name'] as String? ?? json['name'] as String? ?? '',
    status:
        _statusFromApi[json['employment_status']] ?? EmploymentStatus.active,
    designation: designation is Map
        ? designation['title'] as String?
        : designation as String?,
    department: department is Map
        ? department['name'] as String?
        : department as String?,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
  );
}
