import 'dart:io' show Platform;

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

/// Thin wrapper over the `auth/*` endpoints. Returns raw JSON maps; the
/// repository maps them to entities and classifies errors.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  /// `POST auth/login` → `{ data: {...user}, token: "..." }`.
  Future<({Map<String, dynamic> user, String token})> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
        'device_name': _deviceName(),
      },
    );
    final body = res.data ?? const {};
    return (
      user: (body['data'] as Map).cast<String, dynamic>(),
      token: body['token'] as String,
    );
  }

  /// `GET auth/me` → `{ data: {...user} }`.
  Future<Map<String, dynamic>> me() async {
    final res = await _client.get<Map<String, dynamic>>('/auth/me');
    return ((res.data ?? const {})['data'] as Map).cast<String, dynamic>();
  }

  /// `POST auth/logout` — best effort.
  Future<void> logout() async {
    try {
      await _client.post<void>('/auth/logout');
    } on DioException {
      // The caller clears local state regardless.
    }
  }

  String _deviceName() {
    try {
      return '${Platform.operatingSystem} · BizOps 360 mobile';
    } catch (_) {
      return 'BizOps 360 mobile';
    }
  }
}
