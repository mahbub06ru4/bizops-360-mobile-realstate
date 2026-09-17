import '../../core/error/result.dart';
import '../../domain/entities/tenant_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/tenant_user_mappers.dart';
import 'remote_guard.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remote);

  final UserRemoteDataSource _remote;

  @override
  Future<Result<List<TenantUser>>> users() {
    return guardRequest(
      () async => (await _remote.users())
          .map(tenantUserFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<List<RoleInfo>>> roles() {
    return guardRequest(
      () async =>
          (await _remote.roles()).map(roleInfoFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<TenantUser>> assignRoles(
    String userId,
    List<String> roleNames,
  ) {
    return guardRequest(
      () async =>
          tenantUserFromJson(await _remote.assignRoles(userId, roleNames)),
    );
  }
}
