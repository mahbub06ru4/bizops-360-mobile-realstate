import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the live `billing/*` endpoints — see
/// `domain/repositories/billing_repository.dart` for the full contract.
class BillingRemoteDataSource {
  BillingRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /billing/plans` -> `{data: [{code, name, price_amount,
  /// billing_interval, features}]}`.
  Future<List<Map<String, dynamic>>> plans() async {
    final res = await _client.get<Map<String, dynamic>>('/billing/plans');
    return envelopeList(res.data);
  }

  /// `PUT /billing/subscription` `{plan_code}` — tenant-scoped.
  Future<void> selectPlan(String planCode) async {
    await _client.put<Map<String, dynamic>>(
      '/billing/subscription',
      body: {'plan_code': planCode},
    );
  }
}
