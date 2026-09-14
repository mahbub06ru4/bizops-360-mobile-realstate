import 'package:dio/dio.dart';

import '../storage/secure_store.dart';

/// Attaches the bearer token and the JSON headers to every request, and
/// signals a single [onUnauthorized] callback when the server rejects the
/// token (401) so the app can end the session once, centrally.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStore secureStore,
    required Future<void> Function() onUnauthorized,
  }) : _secureStore = secureStore,
       _onUnauthorized = onUnauthorized;

  final SecureStore _secureStore;
  final Future<void> Function() _onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.putIfAbsent('Accept', () => 'application/json');
    final token = await _secureStore.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthEndpoint = err.requestOptions.path.contains('/auth/login');
    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      await _onUnauthorized();
    }
    handler.next(err);
  }
}
