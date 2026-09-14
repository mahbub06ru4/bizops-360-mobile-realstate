import '../../core/error/result.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/finance_remote_datasource.dart';
import '../models/invoice_mappers.dart';
import 'remote_guard.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  InvoiceRepositoryImpl(this._remote);

  final FinanceRemoteDataSource _remote;

  @override
  Future<Result<List<Invoice>>> invoices() {
    return guardRequest(
      () async => (await _remote.invoices())
          .map(invoiceFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<Invoice>> byId(String id) {
    return guardRequest(() async => invoiceFromJson(await _remote.invoice(id)));
  }

  @override
  Future<Result<Invoice>> recordPayment({
    required String invoiceId,
    required num amount,
    required String method,
    String? note,
  }) {
    return guardRequest(() async {
      // Backend `RecordInvoicePaymentRequest` requires `paid_on`; the caller
      // doesn't have a date to pick, so default to today.
      final body = <String, dynamic>{
        'amount': amount,
        'method': method,
        'paid_on': DateTime.now().toIso8601String().split('T').first,
      };
      if (note != null) body['note'] = note;
      return invoiceFromJson(await _remote.recordPayment(invoiceId, body));
    });
  }

  @override
  Future<Result<Invoice>> createFromReference({
    required String customerName,
    required num amount,
    required DateTime dueDate,
    String? bookingReference,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        'customer_name': customerName,
        'amount': amount,
        'due_date': dueDate.toIso8601String().split('T').first,
        'booking_reference': ?bookingReference,
      };
      return invoiceFromJson(await _remote.createInvoice(body));
    });
  }
}
