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

  /// Demo-only entry point for the platform-level buyer persona (`docs/
  /// HANDOFF.md` Phase 2) — "Continue as Buyer" on the sign-in screen. No
  /// backend buyer-auth endpoint exists yet, so [AuthRepositoryImpl] returns a
  /// failure until one lands (assumed shape: `POST /auth/buyer/demo-login` ->
  /// the same `{data:{…user}, token}` envelope as `auth/login`, with the user
  /// object carrying no `tenant`/`roles`); only [FakeAuthRepository]
  /// fabricates a session today.
  Future<Result<AuthUser>> continueAsBuyer();

  /// Self-serve tenant onboarding (roadmap §7 Phase 3) — "Create your
  /// business" on the sign-in screen. Confirmed live in `bizops360-api`:
  /// `POST /api/v1/auth/register` `{company_name, industry?, owner_name,
  /// owner_email, owner_password, owner_password_confirmation}` -> the same
  /// `{data: {...user}, token}` envelope as `auth/login`. [industry] is
  /// nullable and accepts `travel|real_estate|consultancy`; this app defaults
  /// it to `real_estate` on the form but does not hardcode the field away.
  /// On success the returned [AuthUser] is the new tenant's owner — the
  /// caller proceeds to plan selection, then the normal staff shell.
  Future<Result<AuthUser>> register({
    required String companyName,
    String? industry,
    required String ownerName,
    required String ownerEmail,
    required String ownerPassword,
    required String ownerPasswordConfirmation,
  });
}
