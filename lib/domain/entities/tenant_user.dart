import 'package:equatable/equatable.dart';

/// Mirrors `TenantUserResource` — a user account, for reference and role
/// assignment. Full user administration (creating accounts, deactivating)
/// stays with the Next.js admin panel; the mobile app only reads this list
/// and reassigns roles.
class TenantUser extends Equatable {
  const TenantUser({
    required this.id,
    required this.name,
    required this.email,
    this.roles = const [],
  });

  final String id;
  final String name;
  final String email;
  final List<String> roles;

  @override
  List<Object?> get props => [id, name, email, roles];
}

/// Mirrors a `RoleResource` entry from `GET /roles`.
class RoleInfo extends Equatable {
  const RoleInfo({required this.name, this.permissions = const []});

  final String name;
  final List<String> permissions;

  @override
  List<Object?> get props => [name, permissions];
}
