import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the assumed buyer-persona endpoints — see
/// `domain/repositories/buyer_repository.dart` for the full documented
/// contract this was written against. No backend module for these exists yet
/// (`docs/HANDOFF.md` Phase 2); this class exists so wiring the real backend
/// later is a one-file change, following this app's `USE_FAKE_DATA` /
/// `FakeXRepository` convention (see `CLAUDE.md` rule 6).
class BuyerRemoteDataSource {
  BuyerRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> browseVerified({String? query}) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/buyer/projects',
      query: {
        'verified': true,
        if (query != null && query.isNotEmpty) 'location': query,
      },
    );
    return envelopeList(res.data);
  }

  Future<List<Map<String, dynamic>>> savedProjects() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/buyer/saved-projects',
    );
    return envelopeList(res.data);
  }

  Future<void> saveProject(String projectId) async {
    await _client.post<Map<String, dynamic>>(
      '/buyer/saved-projects',
      body: {'project_id': projectId},
    );
  }

  Future<void> unsaveProject(String projectId) async {
    await _client.delete<Map<String, dynamic>>(
      '/buyer/saved-projects/$projectId',
    );
  }

  Future<List<Map<String, dynamic>>> myBookings() async {
    final res = await _client.get<Map<String, dynamic>>('/buyer/bookings');
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> booking(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/buyer/bookings/$id');
    return envelopeObject(res.data);
  }
}
