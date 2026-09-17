import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

class TeamRemoteDataSource {
  TeamRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> teams() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/teams',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> team(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/teams/$id');
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>('/teams', body: body);
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.put<Map<String, dynamic>>(
      '/teams/$id',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<void> delete(String id) => _client.delete<void>('/teams/$id');

  Future<Map<String, dynamic>> setMembers(
    String id,
    List<String> employeeIds,
  ) async {
    final res = await _client.put<Map<String, dynamic>>(
      '/teams/$id/members',
      body: {'members': employeeIds.map(int.parse).toList()},
    );
    return envelopeObject(res.data);
  }
}
