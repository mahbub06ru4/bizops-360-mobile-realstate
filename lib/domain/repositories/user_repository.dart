import '../../core/error/result.dart';
import '../entities/tenant_user.dart';

abstract interface class UserRepository {
  Future<Result<List<TenantUser>>> users();
  Future<Result<List<RoleInfo>>> roles();

  /// Replaces [userId]'s role set with [roleNames]. Sensitive — gated behind
  /// a manager/admin-level check in the UI in addition to `user.assign_roles`.
  Future<Result<TenantUser>> assignRoles(String userId, List<String> roleNames);
}
