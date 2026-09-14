import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';

/// Resolve the stored session on launch / resume: if a token is on the device,
/// validate it and return the user; otherwise `Err(UnauthorizedFailure)`.
class LoadSessionUseCase {
  const LoadSessionUseCase(this._repo);

  final AuthRepository _repo;

  Future<Result<AuthUser>> call() async {
    if (!await _repo.hasStoredSession()) {
      return const Result.err(UnauthorizedFailure());
    }
    return _repo.currentUser();
  }
}
