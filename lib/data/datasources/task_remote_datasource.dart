import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the `tasks` endpoints. The backend already scopes the list
/// to tasks the caller created or is assigned to unless they hold
/// `task.view_all`.
class TaskRemoteDataSource {
  TaskRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/tasks',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> byId(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/tasks/$id');
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>('/tasks', body: body);
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> changeStatus(String id, String status) async {
    final res = await _client.put<Map<String, dynamic>>(
      '/tasks/$id/status',
      body: {'status': status},
    );
    return envelopeObject(res.data);
  }

  Future<List<Map<String, dynamic>>> comments(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/tasks/$id/comments');
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> addComment(String id, String body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/tasks/$id/comments',
      body: {'body': body},
    );
    return envelopeObject(res.data);
  }
}
