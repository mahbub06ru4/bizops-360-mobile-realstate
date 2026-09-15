import 'package:get/get.dart';

import '../../core/permissions/permission_resolver.dart';
import '../auth/auth_controller.dart';

/// The UI's single door to permission checks. Recomputes a [PermissionResolver]
/// from the live session; `Can` and nav builders read it inside `Obx` so they
/// rebuild on sign-in / sign-out.
class PermissionsController extends GetxController {
  PermissionsController(this._auth);

  final AuthController _auth;

  PermissionResolver get resolver {
    final user = _auth.user;
    if (user == null) return const PermissionResolver.empty();
    return PermissionResolver(
      permissions: user.permissions.toSet(),
      roles: user.roles.toSet(),
      industry: user.tenant?.industry,
      isBuyer: user.isBuyer,
    );
  }

  bool can(String permission) => resolver.can(permission);
  bool canAny(Iterable<String> perms) => resolver.canAny(perms);
  bool allows(String permission, {String? feature}) =>
      resolver.allows(permission, feature: feature);

  /// The tenant's industry runs real estate — real-estate-only nav and
  /// dashboard sections gate on this, not just on a permission the owner role
  /// happens to hold in every industry.
  bool get isRealEstate => resolver.isRealEstate;

  /// The signed-in session is the platform-level buyer persona — routes to
  /// the buyer shell instead of the staff shell, and to a much smaller set of
  /// screens. See `docs/HANDOFF.md` Phase 2.
  bool get isBuyer => resolver.isBuyer;
}
