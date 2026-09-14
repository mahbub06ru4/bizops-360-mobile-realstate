import 'package:get/get.dart';

import '../../../application/navigation/shell_controller.dart';
import '../../../modules/travel/visa/bindings/visa_bindings.dart';
import '../../crm/bindings/crm_bindings.dart';
import '../../notifications/bindings/notifications_binding.dart';
import '../../tasks/bindings/tasks_binding.dart';

/// The shell embeds its tab screens as widgets (not routes), so their feature
/// bindings run here rather than per-route.
class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(() => ShellController(Get.find()));
    TasksBinding().dependencies();
    CustomersBinding().dependencies();
    FollowUpsBinding().dependencies();
    VisaQueueBinding().dependencies();
    NotificationsBinding().dependencies();
  }
}
