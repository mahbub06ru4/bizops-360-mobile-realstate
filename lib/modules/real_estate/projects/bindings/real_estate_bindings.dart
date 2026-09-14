import 'package:get/get.dart';

import '../../../../data/datasources/real_estate_remote_datasource.dart';
import '../../../../data/repositories/fake_real_estate_project_repository.dart';
import '../../../../data/repositories/real_estate_project_repository_impl.dart';
import '../../../../data/repositories/repo_registry.dart';
import '../../../../domain/entities/real_estate_project.dart';
import '../../../../domain/repositories/real_estate_project_repository.dart';
import '../controllers/post_project_controller.dart';
import '../controllers/project_detail_controller.dart';
import '../controllers/projects_controller.dart';

/// Public so `MyProjectsSection` (Home dashboard) and the shell tab can pull
/// `RealEstateProjectRepository` in without a full `ProjectsBinding`.
void ensureRealEstateProjectRepo() => registerRepo<RealEstateProjectRepository>(
  (client) =>
      RealEstateProjectRepositoryImpl(RealEstateRemoteDataSource(client)),
  FakeRealEstateProjectRepository.new,
);

class ProjectsBinding extends Bindings {
  @override
  void dependencies() {
    ensureRealEstateProjectRepo();
    Get.lazyPut<ProjectsController>(() => ProjectsController(Get.find()));
  }
}

class ProjectDetailBinding extends Bindings {
  @override
  void dependencies() {
    ensureRealEstateProjectRepo();
    final arg = Get.arguments;
    final seed = arg is RealEstateProject ? arg : null;
    final id = seed?.id ?? (arg is String ? arg : '');
    Get.lazyPut<ProjectDetailController>(
      () => ProjectDetailController(Get.find(), id, seed: seed),
    );
  }
}

class PostProjectBinding extends Bindings {
  @override
  void dependencies() {
    ensureRealEstateProjectRepo();
    Get.lazyPut<PostProjectController>(() => PostProjectController(Get.find()));
  }
}
