import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Pulls the manager dashboard from the per-module overview reports. There is no
/// single `/reports/overview` yet, so this composes CRM + Finance (+ Travel when
/// the tenant is a travel agency).
class ReportRemoteDataSource {
  ReportRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> _get(String path) async {
    final res = await _client.get<Map<String, dynamic>>(path);
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> crmOverview() => _get('/crm/overview');

  Future<Map<String, dynamic>> financeOverview() => _get('/finance/overview');

  Future<Map<String, dynamic>> customerDues() => _get('/finance/customer-dues');

  Future<Map<String, dynamic>> financeMonthly() => _get('/finance/monthly');

  /// Travel overview is `industry:travel` gated — a 403/404 for a non-travel
  /// tenant is expected and yields an empty map, not an error.
  Future<Map<String, dynamic>> travelOverview() async {
    try {
      return await _get('/travel/overview');
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      if (code == 403 || code == 404) return const {};
      rethrow;
    }
  }
}
