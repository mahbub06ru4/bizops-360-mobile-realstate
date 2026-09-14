import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the `customers` / `follow-ups` endpoints.
class CrmRemoteDataSource {
  CrmRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> customers() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/customers',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> customer(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/customers/$id');
    return envelopeObject(res.data);
  }

  /// `GET /customers/{id}/history` → `{ data: { customer, activities:[…], … } }`.
  Future<Map<String, dynamic>> history(String id) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/customers/$id/history',
    );
    return envelopeObject(res.data);
  }

  Future<List<Map<String, dynamic>>> followUps() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/follow-ups',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> completeFollowUp(
    String id,
    String outcome,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/follow-ups/$id/complete',
      body: {'outcome': outcome},
    );
    return envelopeObject(res.data);
  }
}
