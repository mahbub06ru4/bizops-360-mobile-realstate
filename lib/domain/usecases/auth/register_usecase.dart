import '../../../core/error/result.dart';
import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';

/// Self-serve tenant onboarding — "Create your business" on the sign-in
/// screen (roadmap §7 Phase 3). The token is persisted inside the repository
/// on success, same as [SignInUseCase].
class RegisterUseCase {
  const RegisterUseCase(this._repo);

  final AuthRepository _repo;

  Future<Result<AuthUser>> call({
    required String companyName,
    String? industry,
    required String ownerName,
    required String ownerEmail,
    required String ownerPassword,
    required String ownerPasswordConfirmation,
  }) => _repo.register(
    companyName: companyName,
    industry: industry,
    ownerName: ownerName,
    ownerEmail: ownerEmail,
    ownerPassword: ownerPassword,
    ownerPasswordConfirmation: ownerPasswordConfirmation,
  );
}
