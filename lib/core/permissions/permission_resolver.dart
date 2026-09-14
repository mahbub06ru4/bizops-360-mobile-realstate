import 'package:equatable/equatable.dart';

/// Pure, synchronous answer to "may this user see X?". Built from the session
/// and passed around; holds no Flutter or GetX. The UI reads it through
/// `PermissionsController` / the `Can` widget.
class PermissionResolver extends Equatable {
  const PermissionResolver({
    this.permissions = const {},
    this.roles = const {},
    this.enabledFeatures = const {},
    this.industry,
  });

  const PermissionResolver.empty() : this();

  final Set<String> permissions;
  final Set<String> roles;

  /// Feature flags enabled for the tenant (from `/me/bootstrap`). When empty,
  /// every feature is treated as enabled (pre-bootstrap fallback).
  final Set<String> enabledFeatures;

  /// `travel` | `real_estate` | `consultancy` | null.
  final String? industry;

  bool get isTravel => industry == 'travel';

  bool hasRole(String role) => roles.contains(role);

  static const _elevatedRoles = {'owner', 'admin', 'manager'};
  bool get isManager => roles.any(_elevatedRoles.contains);

  /// True when the user holds [permission].
  bool can(String permission) => permissions.contains(permission);

  bool canAny(Iterable<String> perms) => perms.any(permissions.contains);

  bool canAll(Iterable<String> perms) => perms.every(permissions.contains);

  /// True when [feature] is enabled for the tenant (or flags are unknown).
  bool featureEnabled(String feature) =>
      enabledFeatures.isEmpty || enabledFeatures.contains(feature);

  /// The common gate: the feature is on *and* the user holds the permission.
  bool allows(String permission, {String? feature}) =>
      can(permission) && (feature == null || featureEnabled(feature));

  @override
  List<Object?> get props => [permissions, roles, enabledFeatures, industry];
}
