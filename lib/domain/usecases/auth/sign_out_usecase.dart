import '../../repositories/auth_repository.dart';

/// Revoke the device token server-side and clear it locally. Local state is
/// cleared even if the network call fails.
class SignOutUseCase {
  const SignOutUseCase(this._repo);

  final AuthRepository _repo;

  Future<void> call() => _repo.signOut();
}
