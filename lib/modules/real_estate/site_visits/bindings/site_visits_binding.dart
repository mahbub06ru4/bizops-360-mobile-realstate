import 'package:get/get.dart';

import '../../../../data/datasources/real_estate_pipeline_remote_datasource.dart';
import '../../../../data/repositories/fake_site_visit_repository.dart';
import '../../../../data/repositories/repo_registry.dart';
import '../../../../data/repositories/site_visit_repository_impl.dart';
import '../../../../domain/repositories/site_visit_repository.dart';
import '../../../../presentation/crm/bindings/crm_bindings.dart';
import '../../projects/bindings/real_estate_bindings.dart';
import '../controllers/site_visits_controller.dart';

void _ensureSiteVisitRepo() => registerRepo<SiteVisitRepository>(
  (client) =>
      SiteVisitRepositoryImpl(RealEstatePipelineRemoteDataSource(client)),
  FakeSiteVisitRepository.new,
);

/// Argument shape for reaching this screen from a project's unit list
/// ("Schedule visit") — pre-fills the schedule sheet's project/unit.
typedef ScheduleVisitArgs = ({
  String projectId,
  String projectTitle,
  String unitId,
  String unitName,
});

class SiteVisitsBinding extends Bindings {
  @override
  void dependencies() {
    _ensureSiteVisitRepo();
    ensureCrmRepo();
    ensureRealEstateProjectRepo();
    final arg = Get.arguments;
    final prefill = arg is ScheduleVisitArgs ? arg : null;
    Get.lazyPut<SiteVisitsController>(
      () => SiteVisitsController(
        Get.find(),
        Get.find(),
        Get.find(),
        prefillProjectId: prefill?.projectId,
        prefillUnitId: prefill?.unitId,
        prefillUnitName: prefill?.unitName,
      ),
    );
  }
}
