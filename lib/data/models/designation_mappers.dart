import '../../domain/entities/designation.dart';

/// Verified against `DesignationResource` / `DesignationRequest`.
Designation designationFromJson(Map<String, dynamic> json) {
  final department = json['department'];
  return Designation(
    id: json['id'].toString(),
    title: json['title'] as String? ?? '',
    departmentId: json['department_id']?.toString(),
    departmentName: department is Map ? department['name'] as String? : null,
    rank: json['rank'] as int?,
  );
}

Map<String, dynamic> designationInputToJson(DesignationInput input) => {
  'title': input.title,
  if (input.departmentId != null)
    'department_id': int.tryParse(input.departmentId!),
  if (input.rank != null) 'rank': input.rank,
};
