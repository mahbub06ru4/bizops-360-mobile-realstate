import '../../domain/entities/team.dart';
import 'employee_mappers.dart';

/// Verified against `TeamResource` / `TeamRequest` / `TeamMembersRequest`.
Team teamFromJson(Map<String, dynamic> json) {
  final members = json['members'];
  return Team(
    id: json['id'].toString(),
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    leadEmployeeId: json['lead_employee_id']?.toString(),
    membersCount: json['members_count'] as int? ?? 0,
    members: members is List
        ? members
              .whereType<Map<dynamic, dynamic>>()
              .map((e) => employeeFromJson(e.cast<String, dynamic>()))
              .toList(growable: false)
        : const [],
  );
}

Map<String, dynamic> teamInputToJson(TeamInput input) => {
  'name': input.name,
  if (input.description != null) 'description': input.description,
  if (input.leadEmployeeId != null)
    'lead_employee_id': int.tryParse(input.leadEmployeeId!),
};
