import '../../core/error/result.dart';
import '../entities/auth_user.dart';

/// The auth contract the presentation layer depends on. The token is handled
/// entirely inside the implementation (written to the keychain on sign-in,
/// cleared on sign-out); callers only ever see an [AuthUser].
abstract interface class AuthRepository {
  /// Exchange credentials for a token + user. Persists the token on success.
  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  });

  /// Re-fetch the current user (session bootstrap on app launch).
  Future<Result<AuthUser>> currentUser();

  /// Revoke the current device token server-side, then clear it locally.
  /// Local state is cleared even if the network call fails.
  Future<void> signOut();

  /// Whether a token is stored on this device (does not prove it is still valid).
  Future<bool> hasStoredSession();
}
