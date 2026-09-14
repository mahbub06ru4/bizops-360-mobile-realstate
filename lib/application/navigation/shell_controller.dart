import 'package:get/get.dart';

import '../../core/permissions/permission_resolver.dart';
import '../../core/permissions/permissions.dart';
import '../permissions/permissions_controller.dart';

/// The distinct shell destinations. The screen for each is resolved in the
/// presentation layer — this controller only decides which appear and in what
/// order.
enum ShellTabId { home, customers, visa, tasks, workspace }

/// Pure tab-selection rule. Travel baseline: Home · Customers · Visa · Tasks ·
/// More, each gated by permission + enabled feature; Home and More always show.
List<ShellTabId> shellTabsFor(PermissionResolver r) => [
  ShellTabId.home,
  if (r.canAny(const [Perm.customerView, Perm.travellerView]))
    ShellTabId.customers,
  if (r.isTravel && r.allows(Perm.visaView, feature: Feature.travelVisa))
    ShellTabId.visa,
  if (r.allows(Perm.taskView, feature: Feature.tasks)) ShellTabId.tasks,
  ShellTabId.workspace,
];

/// Builds the bottom nav from the live session.
class ShellController extends GetxController {
  ShellController(this._perms);

  final PermissionsController _perms;

  final RxInt currentIndex = 0.obs;

  List<ShellTabId> get tabs => shellTabsFor(_perms.resolver);

  void select(int index) => currentIndex.value = index;

  /// Jump straight to a destination by id — used by Home dashboard sections'
  /// "view all" links. No-op if [id] isn't in the current tab set (permission
  /// revoked, feature off, etc).
  void selectTab(ShellTabId id) {
    final i = tabs.indexOf(id);
    if (i >= 0) currentIndex.value = i;
  }
}
