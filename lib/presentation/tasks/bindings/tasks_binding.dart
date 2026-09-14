import 'package:get/get.dart';

import '../../../data/datasources/task_remote_datasource.dart';
import '../../../data/repositories/fake_task_repository.dart';
import '../../../data/repositories/repo_registry.dart';
import '../../../data/repositories/task_repository_impl.dart';
import '../../../domain/repositories/task_repository.dart';
import '../controllers/tasks_controller.dart';

void ensureTaskRepo() => registerRepo<TaskRepository>(
  (client) => TaskRepositoryImpl(TaskRemoteDataSource(client)),
  FakeTaskRepository.new,
);

class TasksBinding extends Bindings {
  @override
  void dependencies() {
    ensureTaskRepo();
    Get.lazyPut<TasksController>(() => TasksController(Get.find()));
  }
}
