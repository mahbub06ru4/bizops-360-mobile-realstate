import '../../core/error/result.dart';
import '../entities/report_overview.dart';

abstract interface class ReportRepository {
  Future<Result<ReportOverview>> overview();
}
