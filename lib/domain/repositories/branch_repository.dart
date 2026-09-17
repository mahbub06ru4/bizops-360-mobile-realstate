import '../../core/error/result.dart';
import '../entities/branch.dart';

abstract interface class BranchRepository {
  Future<Result<List<Branch>>> branches();
  Future<Result<Branch>> createBranch(BranchInput input);
  Future<Result<Branch>> updateBranch(String id, BranchInput input);
  Future<Result<void>> deleteBranch(String id);
}
