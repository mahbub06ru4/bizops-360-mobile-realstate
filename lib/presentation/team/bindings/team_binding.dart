import 'package:get/get.dart';

import '../../../data/datasources/employee_remote_datasource.dart';
import '../../../data/repositories/employee_repository_impl.dart';
import '../../../data/repositories/fake_employee_repository.dart';
import '../../../data/repositories/repo_registry.dart';
import '../../../domain/repositories/employee_repository.dart';
import '../controllers/team_controller.dart';

class TeamBinding extends Bindings {
  @override
  void dependencies() {
    registerRepo<EmployeeRepository>(
      (client) => EmployeeRepositoryImpl(EmployeeRemoteDataSource(client)),
      FakeEmployeeRepository.new,
    );
    Get.lazyPut<TeamController>(() => TeamController(Get.find()));
  }
}
