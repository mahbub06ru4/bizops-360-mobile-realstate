import '../../core/error/result.dart';
import '../../domain/entities/report_overview.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';
import 'remote_guard.dart';

num _num(dynamic v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;
int _int(dynamic v) => _num(v).toInt();

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? v.cast<String, dynamic>() : const {};

/// Composes the manager dashboard from the CRM / Finance / Travel overview
/// endpoints — see [ReportRemoteDataSource].
class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._remote);

  final ReportRemoteDataSource _remote;

  @override
  Future<Result<ReportOverview>> overview() {
    return guardRequest(() async {
      final crm = await _remote.crmOverview();
      final finance = await _remote.financeOverview();
      final dues = await _remote.customerDues();
      final monthly = await _remote.financeMonthly();
      final travel = await _remote.travelOverview();

      final leads = _map(crm['leads']);
      final thisMonth = _map(finance['this_month']);
      final receivables = _map(finance['receivables']);
      final visas = _map(travel['visas']);
      final months = monthly['months'];

      final points = months is List
          ? months
                .whereType<Map<dynamic, dynamic>>()
                .map(
                  (m) => MonthlyPoint(
                    m['label'] as String? ?? '',
                    _num(m['income']),
                  ),
                )
                .toList()
          : <MonthlyPoint>[];

      return ReportOverview(
        convertedThisMonth: _int(leads['converted']),
        pipelineValue: _num(leads['open_pipeline_value']),
        revenueThisMonth: _num(thisMonth['income']),
        outstanding: _num(receivables['outstanding_amount']),
        customerDues: _num(dues['total_due']),
        visaApproved: _int(visas['approved_this_month']),
        visaInProgress: _int(visas['in_progress']),
        monthlyRevenue: points.length > 6
            ? points.sublist(points.length - 6)
            : points,
      );
    });
  }
}
