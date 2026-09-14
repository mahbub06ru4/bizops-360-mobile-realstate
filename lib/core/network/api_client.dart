import 'package:dio/dio.dart';

import '../config/env.dart';
import 'auth_interceptor.dart';

/// The single configured [Dio] for the app. Data sources depend on this, never
/// on `Dio()` directly.
class ApiClient {
  ApiClient(this._dio);

  /// Builds a Dio pointed at the active flavor's API root, with the auth
  /// interceptor wired to [onUnauthorized] (called once when a token is
  /// rejected).
  factory ApiClient.configured({
    required AuthInterceptor authInterceptor,
    List<Interceptor> extra = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiRoot,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const {'Accept': 'application/json'},
        // Let non-2xx flow through as DioException; the mapper classifies them.
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    dio.interceptors.add(authInterceptor);
    dio.interceptors.addAll(extra);
    if (!Env.isProd) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
        ),
      );
    }
    return ApiClient(dio);
  }

  final Dio _dio;

  Dio get raw => _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) =>
      _dio.get<T>(path, queryParameters: query);

  Future<Response<T>> post<T>(String path, {Object? body}) =>
      _dio.post<T>(path, data: body);

  Future<Response<T>> put<T>(String path, {Object? body}) =>
      _dio.put<T>(path, data: body);

  Future<Response<T>> patch<T>(String path, {Object? body}) =>
      _dio.patch<T>(path, data: body);

  Future<Response<T>> delete<T>(String path, {Object? body}) =>
      _dio.delete<T>(path, data: body);
}
