import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

class BranchRemoteDataSource {
  BranchRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> branches() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/branches',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/branches',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.put<Map<String, dynamic>>(
      '/branches/$id',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<void> delete(String id) => _client.delete<void>('/branches/$id');
}
