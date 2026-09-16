import '../../domain/entities/billing_plan.dart';

BillingPlan billingPlanFromJson(Map<String, dynamic> json) => BillingPlan(
  code: json['code'] as String,
  name: json['name'] as String,
  priceAmount: (json['price_amount'] as num?) ?? 0,
  billingInterval: (json['billing_interval'] as String?) ?? 'monthly',
  features: (json['features'] as List?)?.cast<String>() ?? const [],
);
