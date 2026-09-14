import '../../core/error/result.dart';
import '../entities/invoice.dart';

abstract interface class InvoiceRepository {
  /// All invoices the current user may see, newest due-date first.
  Future<Result<List<Invoice>>> invoices();

  Future<Result<Invoice>> byId(String id);

  /// Record a payment against an invoice (`Actions/Invoices/RecordPayment`).
  /// The invoice moves to `partial` or `paid` depending on the new total.
  Future<Result<Invoice>> recordPayment({
    required String invoiceId,
    required num amount,
    required String method,
    String? note,
  });

  /// Raises a new invoice for another module's billable line item — used by
  /// the real-estate booking/installment flow's "generate invoice" action
  /// (roadmap §7: installments are wired into this existing Finance module
  /// rather than a parallel ledger). [bookingReference] carries a
  /// human-readable reference back to the originating booking/installment.
  Future<Result<Invoice>> createFromReference({
    required String customerName,
    required num amount,
    required DateTime dueDate,
    String? bookingReference,
  });
}
