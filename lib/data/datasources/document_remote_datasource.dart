import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over `GET /employee-documents`. Downloads use the `download_url`
/// each row carries (a temporary signed route) — not wired into the UI yet.
class DocumentRemoteDataSource {
  DocumentRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/employee-documents',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }
}
