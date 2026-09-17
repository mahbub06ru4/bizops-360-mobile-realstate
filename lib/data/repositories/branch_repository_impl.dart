import '../../core/error/result.dart';
import '../../domain/entities/branch.dart';
import '../../domain/repositories/branch_repository.dart';
import '../datasources/branch_remote_datasource.dart';
import '../models/branch_mappers.dart';
import 'remote_guard.dart';

class BranchRepositoryImpl implements BranchRepository {
  BranchRepositoryImpl(this._remote);

  final BranchRemoteDataSource _remote;

  @override
  Future<Result<List<Branch>>> branches() {
    return guardRequest(
      () async => (await _remote.branches())
          .map(branchFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<Branch>> createBranch(BranchInput input) {
    return guardRequest(
      () async =>
          branchFromJson(await _remote.create(branchInputToJson(input))),
    );
  }

  @override
  Future<Result<Branch>> updateBranch(String id, BranchInput input) {
    return guardRequest(
      () async =>
          branchFromJson(await _remote.update(id, branchInputToJson(input))),
    );
  }

  @override
  Future<Result<void>> deleteBranch(String id) {
    return guardRequest(() => _remote.delete(id));
  }
}
