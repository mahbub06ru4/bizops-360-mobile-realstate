import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the `employees` endpoint. `employee.view` gates the
/// list — staff without it get a 403 which surfaces as a "no access" state.
class EmployeeRemoteDataSource {
  EmployeeRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> employees() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/employees',
      query: {'per_page': 200},
    );
    return envelopeList(res.data);
  }
}
