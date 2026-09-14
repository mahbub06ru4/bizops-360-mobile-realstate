import '../../core/error/result.dart';
import '../../domain/entities/site_visit.dart';
import '../../domain/repositories/site_visit_repository.dart';
import '../datasources/real_estate_pipeline_remote_datasource.dart';
import '../models/real_estate_pipeline_mappers.dart';
import 'remote_guard.dart';

class SiteVisitRepositoryImpl implements SiteVisitRepository {
  SiteVisitRepositoryImpl(this._remote);

  final RealEstatePipelineRemoteDataSource _remote;

  @override
  Future<Result<List<SiteVisit>>> list({String? status}) {
    return guardRequest(
      () async => (await _remote.siteVisits(
        status: status,
      )).map(siteVisitFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<SiteVisit>> schedule({
    required String leadId,
    required String leadName,
    required DateTime scheduledAt,
    String? unitId,
    String? unitName,
    String? projectId,
    String? projectTitle,
    String? conductedByEmployeeId,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        'unit_id': ?unitId,
        'project_id': ?projectId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'conducted_by_employee_id': ?conductedByEmployeeId,
      };
      return siteVisitFromJson(await _remote.scheduleSiteVisit(leadId, body));
    });
  }

  @override
  Future<Result<SiteVisit>> complete(String id, {String? feedback}) {
    return guardRequest(
      () async => siteVisitFromJson(
        await _remote.completeSiteVisit(id, feedback: feedback),
      ),
    );
  }

  @override
  Future<Result<SiteVisit>> cancel(String id) {
    return guardRequest(
      () async => siteVisitFromJson(await _remote.cancelSiteVisit(id)),
    );
  }
}
