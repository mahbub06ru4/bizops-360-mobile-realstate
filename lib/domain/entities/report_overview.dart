import 'package:equatable/equatable.dart';

class MonthlyPoint extends Equatable {
  const MonthlyPoint(this.label, this.value);

  final String label;
  final num value;

  @override
  List<Object?> get props => [label, value];
}

/// The manager dashboard payload — a flattened read-model, not per-module
/// queries. Mirrors what a `GET /reports/overview` would return.
class ReportOverview extends Equatable {
  const ReportOverview({
    required this.convertedThisMonth,
    required this.pipelineValue,
    required this.revenueThisMonth,
    required this.outstanding,
    required this.customerDues,
    required this.visaApproved,
    required this.visaInProgress,
    required this.monthlyRevenue,
  });

  final int convertedThisMonth;
  final num pipelineValue;
  final num revenueThisMonth;
  final num outstanding;
  final num customerDues;
  final int visaApproved;
  final int visaInProgress;
  final List<MonthlyPoint> monthlyRevenue;

  @override
  List<Object?> get props => [
    convertedThisMonth,
    pipelineValue,
    revenueThisMonth,
    outstanding,
    customerDues,
    visaApproved,
    visaInProgress,
    monthlyRevenue,
  ];
}
