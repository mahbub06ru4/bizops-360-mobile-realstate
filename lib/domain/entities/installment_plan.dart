import 'package:equatable/equatable.dart';

import 'installment.dart';

enum InstallmentFrequency { monthly, quarterly }

/// A booking's payment schedule (roadmap §7 "Booking → Installment", wired
/// into the existing Finance module for the actual invoice/payment side —
/// this only tracks the schedule shape, not payment-gateway reconciliation).
/// The backend generates and returns [installments] together with the plan
/// in one call — there is no separate installments-list endpoint.
class InstallmentPlan extends Equatable {
  const InstallmentPlan({
    required this.id,
    required this.bookingId,
    required this.downPaymentAmount,
    required this.installmentCount,
    required this.frequency,
    required this.startDate,
    this.installments = const [],
    this.createdAt,
  });

  final String id;
  final String bookingId;

  /// An absolute BDT amount — not a percent. The remainder is split across
  /// [installmentCount] equal installments (the last one absorbs any
  /// rounding remainder).
  final num downPaymentAmount;
  final int installmentCount;
  final InstallmentFrequency frequency;
  final DateTime startDate;

  final List<Installment> installments;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    bookingId,
    downPaymentAmount,
    installmentCount,
    frequency,
    startDate,
    installments,
    createdAt,
  ];
}

/// Splits [financedAmount] into [count] equal installments (rounded to 2
/// decimals), with the last installment absorbing whatever rounding
/// remainder is left so the schedule always sums back to exactly
/// [financedAmount]. Pure math — shared by the fake repository and available
/// to a real backend-shape sanity check in tests.
List<num> splitInstallmentAmounts(num financedAmount, int count) {
  if (count <= 0) return const [];
  if (count == 1) return [financedAmount];
  final each = num.parse((financedAmount / count).toStringAsFixed(2));
  final amounts = List<num>.filled(count, each);
  final sumOfFirst = each * (count - 1);
  amounts[count - 1] = num.parse(
    (financedAmount - sumOfFirst).toStringAsFixed(2),
  );
  return amounts;
}
