import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the `expenses` / `invoices` endpoints. `expense.view` /
/// `invoice.view` gate the lists — staff without them get a 403 which surfaces
/// as a "no access" state.
class FinanceRemoteDataSource {
  FinanceRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> expenses() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/expenses',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/expenses',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<List<Map<String, dynamic>>> pendingExpenses() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/expenses',
      query: {'per_page': 100, 'status': 'pending'},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> decideExpense(
    String id, {
    required bool approve,
    String? note,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/expenses/$id/${approve ? 'approve' : 'reject'}',
      body: {if (note != null && note.isNotEmpty) 'note': note},
    );
    return envelopeObject(res.data);
  }

  // Invoices — endpoint shape follows the rest of the app's REST convention;
  // not yet confirmed against a running backend (spec §6 names the actions
  // `CreateInvoice` / `RecordPayment` but doesn't fix routes).
  Future<List<Map<String, dynamic>>> invoices() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/invoices',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> invoice(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/invoices/$id');
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> createInvoice(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/invoices',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> recordPayment(
    String invoiceId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/invoices/$invoiceId/payments',
      body: body,
    );
    return envelopeObject(res.data);
  }
}
