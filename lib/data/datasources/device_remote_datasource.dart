import '../../core/network/api_client.dart';

/// Thin wrapper over `POST /devices` / `DELETE /devices/{token}` (planned 7a).
class DeviceRemoteDataSource {
  DeviceRemoteDataSource(this._client);

  final ApiClient _client;

  Future<void> register({required String token, required String platform}) =>
      _client.post<void>(
        '/devices',
        body: {'token': token, 'platform': platform},
      );

  Future<void> unregister(String token) =>
      _client.delete<void>('/devices/$token');
}
