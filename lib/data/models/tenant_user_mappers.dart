import '../../domain/entities/tenant_user.dart';

/// Verified against `TenantUserResource` / `RoleResource`.
TenantUser tenantUserFromJson(Map<String, dynamic> json) {
  final roles = json['roles'];
  return TenantUser(
    id: json['id'].toString(),
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    roles: roles is List ? roles.whereType<String>().toList() : const [],
  );
}

RoleInfo roleInfoFromJson(Map<String, dynamic> json) {
  final permissions = json['permissions'];
  return RoleInfo(
    name: json['name'] as String? ?? '',
    permissions: permissions is List
        ? permissions.whereType<String>().toList()
        : const [],
  );
}
