import '../../domain/entities/invoice.dart';

/// `InvoiceResource` / `InvoicePaymentResource` ↔ [Invoice]. Verified against
/// `app/Modules/Finance/Http/Resources/InvoiceResource.php` and
/// `InvoicePaymentResource.php`: the invoice reference field is `number`
/// (not `invoice_number`), the running-paid total is `amount_paid` (not
/// `paid_amount`), and a payment's date is `paid_on` (not `paid_at`).
/// `amount`/`amount_paid` are decimal-string minor-unit-free values
/// (`Money::fromDecimal`, same convention as the live expense mapper), so
/// they parse the same way here. `booking` is present only on an invoice
/// raised from `POST /bookings/{id}/invoice` (`{id, reference, pnr}`); a
/// standalone invoice has no booking and `bookingReference` is null.
const Map<String, InvoiceStatus> _statusFromApi = {
  // Backend InvoiceStatus: draft, sent, partial, paid, refunded, void.
  'draft': InvoiceStatus.unpaid,
  'sent': InvoiceStatus.unpaid,
  'unpaid': InvoiceStatus.unpaid,
  'partially_paid': InvoiceStatus.partial,
  'partial': InvoiceStatus.partial,
  'paid': InvoiceStatus.paid,
  'overdue': InvoiceStatus.overdue,
  'refunded': InvoiceStatus.cancelled,
  'cancelled': InvoiceStatus.cancelled,
  'void': InvoiceStatus.cancelled,
};

const Map<InvoiceStatus, String> invoiceStatusToApi = {
  InvoiceStatus.unpaid: 'sent',
  InvoiceStatus.partial: 'partial',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.overdue: 'sent',
  InvoiceStatus.cancelled: 'void',
};

num _money(dynamic v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;

DateTime _date(dynamic v) =>
    DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();

InvoicePayment invoicePaymentFromJson(Map<String, dynamic> json) {
  return InvoicePayment(
    id: json['id'].toString(),
    amount: _money(json['amount']),
    method:
        json['method'] as String? ?? json['payment_method'] as String? ?? '',
    paidAt: _date(json['paid_on'] ?? json['paid_at'] ?? json['created_at']),
    note: json['note'] as String?,
  );
}

Invoice invoiceFromJson(Map<String, dynamic> json) {
  final customer = json['customer'];
  final booking = json['booking'];
  final payments = json['payments'];

  return Invoice(
    id: json['id'].toString(),
    reference:
        json['number'] as String? ??
        json['invoice_number'] as String? ??
        json['reference'] as String? ??
        '',
    customerName:
        (customer is Map ? customer['name'] as String? : null) ??
        json['customer_name'] as String? ??
        '',
    amount: _money(json['amount'] ?? json['total_amount']),
    paidAmount: _money(json['amount_paid'] ?? json['paid_amount']),
    dueDate: _date(json['due_date']),
    status: _statusFromApi[json['status']] ?? InvoiceStatus.unpaid,
    bookingReference: booking is Map
        ? (booking['reference'] as String? ?? booking['pnr'] as String?)
        : null,
    payments: payments is List
        ? payments
              .whereType<Map<dynamic, dynamic>>()
              .map((p) => invoicePaymentFromJson(p.cast<String, dynamic>()))
              .toList(growable: false)
        : const [],
  );
}
