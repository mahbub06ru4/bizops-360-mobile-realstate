import 'dart:async';

import 'package:get/get.dart';

import '../../../../application/permissions/permissions_controller.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/permissions/permissions.dart';
import '../../../../core/state/async_value.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../domain/entities/tenant_user.dart';
import '../../../../domain/repositories/user_repository.dart';

/// Users + role assignment — reference only. Full user administration
/// (creating accounts, deactivating) stays with the Next.js admin panel.
/// Role assignment is sensitive: gated behind `user.assign_roles` *and* a
/// manager/admin-level role, mirroring `PermissionResolver.isManager`.
class UsersController extends GetxController {
  UsersController(this._repo, this._permissions);

  final UserRepository _repo;
  final PermissionsController _permissions;

  final Rx<AsyncValue<List<TenantUser>>> state =
      const AsyncValue<List<TenantUser>>.loading().obs;
  final RxList<RoleInfo> roles = <RoleInfo>[].obs;

  bool get canAssignRoles =>
      _permissions.allows(Perm.userAssignRoles) &&
      _permissions.resolver.isManager;

  @override
  void onInit() {
    super.onInit();
    load();
    if (canAssignRoles) unawaited(_loadRoles());
  }

  Future<void> _loadRoles() async {
    roles.value = (await _repo.roles()).valueOrNull ?? const [];
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.users()).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<bool> assignRoles(TenantUser user, List<String> roleNames) async {
    final result = await _repo.assignRoles(user.id, roleNames);
    return result.fold(
      (_) {
        AppSnackbar.show(Tr.orgSaved.tr, tone: FeedbackTone.success);
        unawaited(load());
        return true;
      },
      (failure) {
        AppSnackbar.error(failure.message);
        return false;
      },
    );
  }
}
