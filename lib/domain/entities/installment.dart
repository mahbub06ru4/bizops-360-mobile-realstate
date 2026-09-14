import 'package:equatable/equatable.dart';

/// Phase 1 keeps this a plain schedule status — no payment-gateway fields, no
/// auto-reconciliation (roadmap §7). `invoiced` means an Invoice has been
/// raised in the Finance module ([invoiceId] set) but not yet paid.
enum InstallmentStatus { pending, invoiced, paid, overdue }

/// One line of an [InstallmentPlan]. [invoiceId] links to the *existing*
/// Finance `Invoice` once "generate invoice" has been run — installment
/// payment state is not tracked independently of that invoice from that
/// point on ("mark paid" in Phase 1 sets both together since there is no
/// payment-gateway webhook yet).
class Installment extends Equatable {
  const Installment({
    required this.id,
    required this.installmentPlanId,
    required this.sequence,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.invoiceId,
    this.createdAt,
  });

  final String id;
  final String installmentPlanId;

  /// 1-based position in the schedule.
  final int sequence;

  /// BDT.
  final num amount;
  final DateTime dueDate;
  final InstallmentStatus status;

  /// The Finance `Invoice.id` this installment was billed against, once
  /// generated.
  final String? invoiceId;

  final DateTime? createdAt;

  bool get isOverdue =>
      status != InstallmentStatus.paid && dueDate.isBefore(DateTime.now());

  Installment copyWith({InstallmentStatus? status, String? invoiceId}) =>
      Installment(
        id: id,
        installmentPlanId: installmentPlanId,
        sequence: sequence,
        amount: amount,
        dueDate: dueDate,
        status: status ?? this.status,
        invoiceId: invoiceId ?? this.invoiceId,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
    id,
    installmentPlanId,
    sequence,
    amount,
    dueDate,
    status,
    invoiceId,
    createdAt,
  ];
}
