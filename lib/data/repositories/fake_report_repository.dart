import '../../core/error/result.dart';
import '../../domain/entities/report_overview.dart';
import '../../domain/repositories/report_repository.dart';

/// In-memory manager dashboard for UI-first development (`Env.useFakeData`).
class FakeReportRepository implements ReportRepository {
  @override
  Future<Result<ReportOverview>> overview() => Future.delayed(
    const Duration(milliseconds: 350),
    () => const Result.ok(
      ReportOverview(
        convertedThisMonth: 9,
        pipelineValue: 1830000,
        revenueThisMonth: 1240000,
        outstanding: 385000,
        customerDues: 172000,
        visaApproved: 14,
        visaInProgress: 8,
        monthlyRevenue: [
          MonthlyPoint('Apr', 820000),
          MonthlyPoint('May', 910000),
          MonthlyPoint('Jun', 760000),
          MonthlyPoint('Jul', 1050000),
          MonthlyPoint('Aug', 1180000),
          MonthlyPoint('Sep', 1240000),
        ],
      ),
    ),
  );
}
