import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> users() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/users',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<List<Map<String, dynamic>>> roles() async {
    final res = await _client.get<Map<String, dynamic>>('/roles');
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> assignRoles(
    String userId,
    List<String> roleNames,
  ) async {
    final res = await _client.put<Map<String, dynamic>>(
      '/users/$userId/roles',
      body: {'roles': roleNames},
    );
    return envelopeObject(res.data);
  }
}
