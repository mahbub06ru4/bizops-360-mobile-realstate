import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the `holidays` endpoint.
class HolidayRemoteDataSource {
  HolidayRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> holidays() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/holidays',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }
}
