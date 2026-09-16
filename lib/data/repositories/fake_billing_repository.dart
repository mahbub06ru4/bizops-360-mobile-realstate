import '../../core/error/result.dart';
import '../../domain/entities/billing_plan.dart';
import '../../domain/repositories/billing_repository.dart';

/// In-memory [BillingRepository] for UI-first development (`Env.useFakeData`).
class FakeBillingRepository implements BillingRepository {
  static const _plans = [
    BillingPlan(
      code: 'starter',
      name: 'Starter',
      priceAmount: 2000,
      billingInterval: 'monthly',
      features: ['1 project', 'Up to 3 staff', 'Email support'],
    ),
    BillingPlan(
      code: 'growth',
      name: 'Growth',
      priceAmount: 6000,
      billingInterval: 'monthly',
      features: [
        'Up to 10 projects',
        'Up to 15 staff',
        'Sales pipeline + installments',
        'Priority support',
      ],
    ),
    BillingPlan(
      code: 'enterprise',
      name: 'Enterprise',
      priceAmount: 15000,
      billingInterval: 'monthly',
      features: [
        'Unlimited projects',
        'Unlimited staff',
        'Marketplace listing priority',
        'Dedicated support',
      ],
    ),
  ];

  String? _selected;

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 300), () => value);

  @override
  Future<Result<List<BillingPlan>>> getPlans() =>
      _delayed(const Result.ok(_plans));

  @override
  Future<Result<void>> selectPlan(String planCode) {
    _selected = planCode;
    return _delayed(const Result.ok(null));
  }

  String? get selectedPlanCode => _selected;
}
