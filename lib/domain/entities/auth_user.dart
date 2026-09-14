import 'package:equatable/equatable.dart';

import 'tenant.dart';

/// The signed-in user, as returned by `auth/login` and `auth/me`. Roles and
/// permissions here are already scoped to [tenant] by the backend, so the app
/// can drive its whole navigation and gating from this one object.
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    required this.permissions,
    this.tenant,
  });

  final int id;
  final String name;
  final String email;
  final List<String> roles;
  final List<String> permissions;
  final Tenant? tenant;

  static const _elevatedRoles = {'owner', 'admin', 'manager'};

  bool can(String permission) => permissions.contains(permission);

  bool canAny(Iterable<String> perms) => perms.any(permissions.contains);

  bool hasRole(String role) => roles.contains(role);

  /// Owner, admin or manager — the app shows the team deck and the fifth tab.
  bool get isManager => roles.any(_elevatedRoles.contains);

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    String head(String s) =>
        String.fromCharCodes(s.runes.take(1)).toUpperCase();
    if (parts.length == 1) return head(parts.first);
    return head(parts.first) + head(parts.last);
  }

  @override
  List<Object?> get props => [id, name, email, roles, permissions, tenant];
}
