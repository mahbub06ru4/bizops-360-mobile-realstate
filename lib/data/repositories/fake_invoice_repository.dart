import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';

/// In-memory invoices for UI-first development (`Env.useFakeData`).
class FakeInvoiceRepository implements InvoiceRepository {
  FakeInvoiceRepository() : _items = _seed();

  List<Invoice> _items;
  var _nextInvoiceId = 500;
  var _nextPaymentId = 900;

  static DateTime _days(int d) => DateTime.now().add(Duration(days: d));

  static List<Invoice> _seed() => [
    Invoice(
      id: 'inv1',
      reference: 'INV-2043',
      customerName: 'Nusrat Jahan',
      amount: 320000,
      paidAmount: 320000,
      dueDate: _days(-10),
      status: InvoiceStatus.paid,
      bookingReference: 'LM49XT',
      payments: [
        InvoicePayment(
          id: 'p1',
          amount: 320000,
          method: 'Bank transfer',
          paidAt: _days(-11),
        ),
      ],
    ),
    Invoice(
      id: 'inv2',
      reference: 'INV-2044',
      customerName: 'Karim Rahman',
      amount: 92000,
      paidAmount: 40000,
      dueDate: _days(3),
      status: InvoiceStatus.partial,
      bookingReference: 'BQ7K2P',
      payments: [
        InvoicePayment(
          id: 'p2',
          amount: 40000,
          method: 'bKash',
          paidAt: _days(-2),
        ),
      ],
    ),
    Invoice(
      id: 'inv3',
      reference: 'INV-2038',
      customerName: 'Hasan & family',
      amount: 260000,
      dueDate: _days(-6),
      status: InvoiceStatus.overdue,
    ),
    Invoice(
      id: 'inv4',
      reference: 'INV-2045',
      customerName: 'Sadia Islam',
      amount: 140000,
      dueDate: _days(14),
      status: InvoiceStatus.unpaid,
    ),
  ];

  Future<T> _delayed<T>(T v) =>
      Future<T>.delayed(const Duration(milliseconds: 320), () => v);

  Invoice? _find(String id) => _items.where((i) => i.id == id).firstOrNull;

  Result<Invoice> _replace(Invoice v) {
    _items = [
      for (final x in _items)
        if (x.id == v.id) v else x,
    ];
    return Result.ok(v);
  }

  @override
  Future<Result<List<Invoice>>> invoices() =>
      _delayed(Result.ok(List.unmodifiable(_items)));

  @override
  Future<Result<Invoice>> byId(String id) {
    final v = _find(id);
    return _delayed(
      v == null ? const Result.err(NotFoundFailure()) : Result.ok(v),
    );
  }

  @override
  Future<Result<Invoice>> createFromBooking({
    required String bookingId,
    required DateTime dueDate,
  }) {
    final invoice = Invoice(
      id: 'inv${_nextInvoiceId++}',
      reference: 'INV-${_nextInvoiceId}00',
      customerName: 'Booking $bookingId customer',
      amount: 0,
      dueDate: dueDate,
      status: InvoiceStatus.unpaid,
      bookingReference: bookingId,
    );
    _items = [invoice, ..._items];
    return _delayed(Result.ok(invoice));
  }

  @override
  Future<Result<Invoice>> recordPayment({
    required String invoiceId,
    required num amount,
    required String method,
    String? note,
  }) {
    final invoice = _find(invoiceId);
    if (invoice == null) {
      return _delayed(const Result.err(NotFoundFailure()));
    }
    final paid = invoice.paidAmount + amount;
    final updated = invoice.copyWith(
      paidAmount: paid,
      status: paid >= invoice.amount
          ? InvoiceStatus.paid
          : InvoiceStatus.partial,
      payments: [
        ...invoice.payments,
        InvoicePayment(
          id: 'p${_nextPaymentId++}',
          amount: amount,
          method: method,
          paidAt: DateTime.now(),
          note: note,
        ),
      ],
    );
    return _delayed(_replace(updated));
  }
}
