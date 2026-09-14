import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the `travellers` endpoints (`industry:travel` gated).
/// Returns unwrapped resource objects; the repository maps and classifies.
class TravellerRemoteDataSource {
  TravellerRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _client.get<Map<String, dynamic>>('/travellers');
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> byId(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/travellers/$id');
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/travellers',
      body: body,
    );
    return envelopeObject(res.data);
  }
}
