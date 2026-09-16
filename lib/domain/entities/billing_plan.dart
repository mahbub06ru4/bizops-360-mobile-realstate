import 'package:equatable/equatable.dart';

/// One subscription plan, as returned by `GET /api/v1/billing/plans`
/// (roadmap §7 Phase 3 — self-serve plan selection). Any authed user may
/// fetch this list; no tenant/industry gate.
class BillingPlan extends Equatable {
  const BillingPlan({
    required this.code,
    required this.name,
    required this.priceAmount,
    required this.billingInterval,
    this.features = const [],
  });

  final String code;
  final String name;

  /// BDT.
  final num priceAmount;

  /// e.g. `monthly`, `yearly`.
  final String billingInterval;
  final List<String> features;

  @override
  List<Object?> get props => [
    code,
    name,
    priceAmount,
    billingInterval,
    features,
  ];
}
