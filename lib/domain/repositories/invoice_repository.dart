import '../../core/error/result.dart';
import '../entities/invoice.dart';

abstract interface class InvoiceRepository {
  /// All invoices the current user may see, newest due-date first.
  Future<Result<List<Invoice>>> invoices();

  Future<Result<Invoice>> byId(String id);

  /// Raise an invoice against an issued booking (spec §6
  /// `Actions/Invoices/CreateInvoice`). The backend resolves the customer and
  /// amount from the booking itself.
  Future<Result<Invoice>> createFromBooking({
    required String bookingId,
    required DateTime dueDate,
  });

  /// Record a payment against an invoice (`Actions/Invoices/RecordPayment`).
  /// The invoice moves to `partial` or `paid` depending on the new total.
  Future<Result<Invoice>> recordPayment({
    required String invoiceId,
    required num amount,
    required String method,
    String? note,
  });
}
