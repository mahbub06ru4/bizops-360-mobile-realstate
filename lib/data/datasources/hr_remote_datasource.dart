import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the HR endpoints (attendance + leave). These require the
/// caller's account to be linked to an employee record; otherwise the API
/// returns a 422 which surfaces as an error state.
class HrRemoteDataSource {
  HrRemoteDataSource(this._client);

  final ApiClient _client;

  // Attendance --------------------------------------------------------------

  Future<List<Map<String, dynamic>>> attendance() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/attendance',
      query: {'per_page': 60},
    );
    return envelopeList(res.data);
  }

  /// `zone` ('office' | 'outside') is the client's geofence read — the backend
  /// shape for this is unconfirmed, so the field is sent best-effort and
  /// re-derived from `outside` if the response echoes it back.
  Future<Map<String, dynamic>> checkIn({required String zone}) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/attendance/check-in',
      body: {'zone': zone},
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> checkOut({required String zone}) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/attendance/check-out',
      body: {'zone': zone},
    );
    return envelopeObject(res.data);
  }

  // Office location -----------------------------------------------------

  /// Unconfirmed endpoint — guessed following the app's REST convention.
  Future<Map<String, dynamic>> officeLocation() async {
    final res = await _client.get<Map<String, dynamic>>('/office-location');
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> updateOfficeLocation(
    Map<String, dynamic> body,
  ) async {
    final res = await _client.put<Map<String, dynamic>>(
      '/office-location',
      body: body,
    );
    return envelopeObject(res.data);
  }

  // Leave -----------------------------------------------------------------

  Future<List<Map<String, dynamic>>> leaveBalances() async {
    final res = await _client.get<Map<String, dynamic>>('/leave-balances');
    return envelopeList(res.data);
  }

  Future<List<Map<String, dynamic>>> leaveRequests({String? status}) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/leave-requests',
      query: {'per_page': 60, 'status': ?status},
    );
    return envelopeList(res.data);
  }

  Future<List<Map<String, dynamic>>> leaveTypes() async {
    final res = await _client.get<Map<String, dynamic>>('/leave-types');
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> submitLeave(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/leave-requests',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> decideLeave(
    String id, {
    required bool approve,
    String? note,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/leave-requests/$id/${approve ? 'approve' : 'reject'}',
      body: {if (note != null && note.isNotEmpty) 'note': note},
    );
    return envelopeObject(res.data);
  }
}
