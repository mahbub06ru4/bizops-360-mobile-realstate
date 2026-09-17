import '../../domain/entities/department.dart';

/// Verified against `DepartmentResource` / `DepartmentRequest`.
Department departmentFromJson(Map<String, dynamic> json) {
  final branch = json['branch'];
  return Department(
    id: json['id'].toString(),
    name: json['name'] as String? ?? '',
    code: json['code'] as String? ?? '',
    branchId: json['branch_id']?.toString(),
    branchName: branch is Map ? branch['name'] as String? : null,
    description: json['description'] as String?,
  );
}

Map<String, dynamic> departmentInputToJson(DepartmentInput input) => {
  'name': input.name,
  'code': input.code,
  if (input.branchId != null) 'branch_id': int.tryParse(input.branchId!),
  if (input.description != null) 'description': input.description,
};
