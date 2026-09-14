import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../application/permissions/permissions_controller.dart';

/// Shows [child] only when the session allows it. Otherwise renders [fallback]
/// — nothing by default. Rebuilds on sign-in / sign-out.
///
/// Presentation gating only; the backend still authorizes the call behind any
/// action revealed here.
class Can extends StatelessWidget {
  /// Allowed when the user holds [permission] (and [feature], if given, is on).
  const Can(
    String permission, {
    required this.child,
    String? feature,
    this.travelOnly = false,
    this.fallback = const SizedBox.shrink(),
    super.key,
  }) : _permissions = const [],
       _single = permission,
       _feature = feature;

  /// Allowed when the user holds *any* of [permissions].
  const Can.anyOf(
    List<String> permissions, {
    required this.child,
    this.travelOnly = false,
    this.fallback = const SizedBox.shrink(),
    super.key,
  }) : _permissions = permissions,
       _single = null,
       _feature = null;

  final String? _single;
  final List<String> _permissions;
  final String? _feature;

  /// Also require the tenant's industry to be travel — for nav/actions that a
  /// non-travel owner would otherwise see purely because the `*` role grant
  /// includes the travel permissions.
  final bool travelOnly;

  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final perms = Get.find<PermissionsController>();
    return Obx(() {
      if (travelOnly && !perms.isTravel) return fallback;
      final allowed = _single != null
          ? perms.allows(_single, feature: _feature)
          : perms.canAny(_permissions);
      return allowed ? child : fallback;
    });
  }
}
