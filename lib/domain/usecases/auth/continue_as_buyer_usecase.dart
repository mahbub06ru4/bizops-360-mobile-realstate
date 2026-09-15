import '../../../core/error/result.dart';
import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';

/// Demo entry point for the platform-level buyer persona — "Continue as
/// Buyer" on the sign-in screen (`docs/HANDOFF.md` Phase 2). See
/// [AuthRepository.continueAsBuyer] for the assumed real-backend shape.
class ContinueAsBuyerUseCase {
  const ContinueAsBuyerUseCase(this._repo);

  final AuthRepository _repo;

  Future<Result<AuthUser>> call() => _repo.continueAsBuyer();
}
