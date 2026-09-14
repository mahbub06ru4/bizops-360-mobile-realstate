import 'package:equatable/equatable.dart';

/// An installment template a buyer can be offered (roadmap §5
/// `project_payment_plans`). Actual booking/installment tracking is Phase 1+;
/// Phase 0 only captures the template on the project.
class PaymentPlan extends Equatable {
  const PaymentPlan({
    required this.id,
    required this.name,
    required this.downPaymentPercent,
    required this.installmentCount,
    this.installmentAmount,
    this.notes,
  });

  final String id;
  final String name;

  /// e.g. `20` for a 20% down payment.
  final num downPaymentPercent;
  final int installmentCount;

  /// BDT per installment, when the plan is a fixed-amount schedule.
  final num? installmentAmount;
  final String? notes;

  @override
  List<Object?> get props => [
    id,
    name,
    downPaymentPercent,
    installmentCount,
    installmentAmount,
    notes,
  ];
}
