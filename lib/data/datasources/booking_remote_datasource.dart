import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the `bookings` endpoints (`industry:travel` gated).
class BookingRemoteDataSource {
  BookingRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/bookings',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> byId(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/bookings/$id');
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/bookings',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> issue(String id) async {
    final res = await _client.post<Map<String, dynamic>>('/bookings/$id/issue');
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> cancel(String id) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/bookings/$id/cancel',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> raiseInvoice(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/bookings/$id/invoice',
      body: body,
    );
    return envelopeObject(res.data);
  }
}
