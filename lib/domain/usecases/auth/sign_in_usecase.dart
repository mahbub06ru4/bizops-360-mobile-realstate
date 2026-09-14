import '../../../core/error/result.dart';
import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';

/// Exchange email + password for an authenticated [AuthUser]. The token is
/// persisted inside the repository on success.
class SignInUseCase {
  const SignInUseCase(this._repo);

  final AuthRepository _repo;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) => _repo.signIn(email: email, password: password);
}
