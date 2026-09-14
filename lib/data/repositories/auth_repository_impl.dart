import 'package:dio/dio.dart';

import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../core/network/dio_failure_mapper.dart';
import '../../core/storage/secure_store.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_mappers.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SecureStore secureStore,
  }) : _remote = remote,
       _secureStore = secureStore;

  final AuthRemoteDataSource _remote;
  final SecureStore _secureStore;

  @override
  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final result = await _remote.login(email: email, password: password);
      await _secureStore.writeToken(result.token);
      // The login payload carries roles but not `permissions`; hydrate the full
      // profile via `auth/me` so the permission-gated UI (nav, actions) is
      // correct from the first frame. Fall back to the login user if that call
      // fails — the token is already stored, so a resume will hydrate later.
      try {
        return authUserFromJson(await _remote.me());
      } on DioException {
        return authUserFromJson(result.user);
      }
    });
  }

  @override
  Future<Result<AuthUser>> currentUser() {
    return _guard(() async => authUserFromJson(await _remote.me()));
  }

  @override
  Future<void> signOut() async {
    await _remote.logout();
    await _secureStore.clear();
  }

  @override
  Future<bool> hasStoredSession() async {
    final token = await _secureStore.readToken();
    return token != null && token.isNotEmpty;
  }

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Result.ok(await run());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    } on Object {
      return const Result.err(UnknownFailure());
    }
  }
}
