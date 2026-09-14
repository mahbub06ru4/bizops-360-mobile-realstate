import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the `visa-applications` / `visa-requirements` endpoints
/// (`industry:travel` gated). Returns unwrapped resource objects.
class VisaRemoteDataSource {
  VisaRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _client.get<Map<String, dynamic>>('/visa-applications');
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> byId(String id) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/visa-applications/$id',
    );
    return envelopeObject(res.data);
  }

  Future<void> toggleRequirement(
    String requirementId, {
    required bool collected,
  }) {
    return _client.put<void>(
      '/visa-requirements/$requirementId',
      body: {'collected': collected},
    );
  }

  Future<Map<String, dynamic>> submit(String id) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/visa-applications/$id/submit',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> processing(String id) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/visa-applications/$id/processing',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> decision(
    String id, {
    required String outcome,
    required String decisionOn,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/visa-applications/$id/decision',
      body: {'outcome': outcome, 'decision_on': decisionOn},
    );
    return envelopeObject(res.data);
  }
}
