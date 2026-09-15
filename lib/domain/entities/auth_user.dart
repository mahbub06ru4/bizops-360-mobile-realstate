import 'package:equatable/equatable.dart';

import 'tenant.dart';

/// The two personas one login can resolve to (see `docs/HANDOFF.md` Phase 2).
/// [staff] is the existing tenant-scoped persona (owner/admin/manager/staff
/// roles, `tenant` set, drives the whole vertical module). [buyer] is a new
/// platform-level persona: no tenant, no industry, no roles/permissions —
/// just a buyer account browsing verified listings across the (single, for
/// Phase 2) demo tenant's catalogue. There is no backend buyer-auth yet, so
/// only [FakeAuthRepository] can produce a [buyer] session today.
enum UserKind { staff, buyer }

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
    this.kind = UserKind.staff,
    this.phone,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final List<String> roles;
  final List<String> permissions;
  final Tenant? tenant;

  /// [UserKind.staff] unless this session was started via "Continue as
  /// Buyer" on the sign-in screen.
  final UserKind kind;

  bool get isBuyer => kind == UserKind.buyer;

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
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    roles,
    permissions,
    tenant,
    kind,
  ];
}
