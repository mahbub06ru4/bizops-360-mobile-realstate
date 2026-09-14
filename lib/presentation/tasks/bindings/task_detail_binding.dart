import 'package:get/get.dart';

import '../../../domain/entities/task_item.dart';
import '../controllers/task_detail_controller.dart';
import 'tasks_binding.dart';

class TaskDetailBinding extends Bindings {
  @override
  void dependencies() {
    ensureTaskRepo();
    final arg = Get.arguments;
    final seed = arg is TaskItem ? arg : null;
    final id = seed?.id ?? (arg is String ? arg : '');
    Get.lazyPut<TaskDetailController>(
      () => TaskDetailController(Get.find(), id, seed: seed),
    );
  }
}
