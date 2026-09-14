import 'package:get/get.dart';

import '../../../../data/datasources/real_estate_pipeline_remote_datasource.dart';
import '../../../../data/repositories/fake_property_requirement_repository.dart';
import '../../../../data/repositories/property_requirement_repository_impl.dart';
import '../../../../data/repositories/repo_registry.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../domain/repositories/property_requirement_repository.dart';
import '../controllers/matches_controller.dart';
import '../controllers/requirement_form_controller.dart';

void ensurePropertyRequirementRepo() =>
    registerRepo<PropertyRequirementRepository>(
      (client) => PropertyRequirementRepositoryImpl(
        RealEstatePipelineRemoteDataSource(client),
      ),
      FakePropertyRequirementRepository.new,
    );

class RequirementFormBinding extends Bindings {
  @override
  void dependencies() {
    ensurePropertyRequirementRepo();
    final arg = Get.arguments;
    final lead = arg is Customer ? arg : null;
    Get.lazyPut<RequirementFormController>(
      () => RequirementFormController(
        Get.find(),
        lead?.id ?? '',
        lead?.name ?? '',
      ),
    );
  }
}

class MatchesBinding extends Bindings {
  @override
  void dependencies() {
    ensurePropertyRequirementRepo();
    final id = Get.arguments is String ? Get.arguments as String : '';
    Get.lazyPut<MatchesController>(() => MatchesController(Get.find(), id));
  }
}
