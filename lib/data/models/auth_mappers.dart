import '../../domain/entities/auth_user.dart';
import '../../domain/entities/tenant.dart';

/// Parses the `data` object shared by `auth/login`, `auth/register` and
/// `auth/me`. Tolerant of missing `roles` / `permissions` (they are only
/// present when the relations are loaded).
AuthUser authUserFromJson(Map<String, dynamic> json) {
  return AuthUser(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    roles: _stringList(json['roles']),
    permissions: _stringList(json['permissions']),
    tenant: json['tenant'] is Map<String, dynamic>
        ? _tenantFromJson(json['tenant'] as Map<String, dynamic>)
        : null,
  );
}

Tenant _tenantFromJson(Map<String, dynamic> json) {
  return Tenant(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
    industry: json['industry'] as String?,
  );
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList(growable: false);
  }
  return const [];
}
