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
    );
  }

  bool can(String permission) => resolver.can(permission);
  bool canAny(Iterable<String> perms) => resolver.canAny(perms);
  bool allows(String permission, {String? feature}) =>
      resolver.allows(permission, feature: feature);

  /// The tenant's industry runs a travel agency — travel-only nav and dashboard
  /// sections gate on this, not just on a permission the owner role happens to
  /// hold in every industry.
  bool get isTravel => resolver.isTravel;
}
