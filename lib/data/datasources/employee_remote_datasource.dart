import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the `employees` endpoint. `employee.view` gates the
/// list — staff without it get a 403 which surfaces as a "no access" state.
class EmployeeRemoteDataSource {
  EmployeeRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> employees({
    required int page,
    required int perPage,
    String? q,
  }) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/employees',
      query: {
        'page': page,
        'per_page': perPage,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> employee(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/employees/$id');
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/employees',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.put<Map<String, dynamic>>(
      '/employees/$id',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> terminate(String id) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/employees/$id/terminate',
    );
    return envelopeObject(res.data);
  }
}
