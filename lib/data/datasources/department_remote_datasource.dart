import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

class DepartmentRemoteDataSource {
  DepartmentRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> departments() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/departments',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/departments',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.put<Map<String, dynamic>>(
      '/departments/$id',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<void> delete(String id) => _client.delete<void>('/departments/$id');
}
