import 'package:equatable/equatable.dart';

enum InvoiceStatus { unpaid, partial, paid, overdue, cancelled }

class InvoicePayment extends Equatable {
  const InvoicePayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.paidAt,
    this.note,
  });

  final String id;

  /// BDT.
  final num amount;

  /// Free-text — "Cash", "bKash", "Bank transfer", …
  final String method;
  final DateTime paidAt;
  final String? note;

  @override
  List<Object?> get props => [id, amount, method, paidAt, note];
}

class Invoice extends Equatable {
  const Invoice({
    required this.id,
    required this.reference,
    required this.customerName,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidAmount = 0,
    this.bookingReference,
    this.payments = const [],
  });

  final String id;
  final String reference;
  final String customerName;

  /// BDT.
  final num amount;
  final num paidAmount;
  final DateTime dueDate;
  final InvoiceStatus status;

  /// Set when the invoice was raised from a booking.
  final String? bookingReference;
  final List<InvoicePayment> payments;

  num get due => (amount - paidAmount).clamp(0, amount);

  bool get isSettled =>
      status == InvoiceStatus.paid || status == InvoiceStatus.cancelled;

  bool get isPastDue => !isSettled && dueDate.isBefore(DateTime.now());

  Invoice copyWith({
    num? paidAmount,
    InvoiceStatus? status,
    List<InvoicePayment>? payments,
  }) => Invoice(
    id: id,
    reference: reference,
    customerName: customerName,
    amount: amount,
    paidAmount: paidAmount ?? this.paidAmount,
    dueDate: dueDate,
    status: status ?? this.status,
    bookingReference: bookingReference,
    payments: payments ?? this.payments,
  );

  @override
  List<Object?> get props => [
    id,
    reference,
    customerName,
    amount,
    paidAmount,
    dueDate,
    status,
    bookingReference,
    payments,
  ];
}
