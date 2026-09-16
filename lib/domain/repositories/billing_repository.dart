import '../../core/error/result.dart';
import '../entities/billing_plan.dart';

/// Self-serve plan selection (roadmap §7 Phase 3). Confirmed live in
/// `bizops360-api`:
/// ```
/// GET /api/v1/billing/plans                any authed user, no tenant/industry gate
///                                           -> [{code, name, price_amount,
///                                              billing_interval, features}]
/// PUT /api/v1/billing/subscription          tenant-scoped, body {plan_code}
/// ```
abstract interface class BillingRepository {
  Future<Result<List<BillingPlan>>> getPlans();

  Future<Result<void>> selectPlan(String planCode);
}
