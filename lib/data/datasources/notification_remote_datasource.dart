import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the `notifications` endpoints.
class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/notifications',
      query: {'per_page': 50},
    );
    return envelopeList(res.data);
  }

  Future<void> markRead(String id) =>
      _client.patch<void>('/notifications/$id/read');

  Future<void> markAllRead() => _client.post<void>('/notifications/read-all');
}
