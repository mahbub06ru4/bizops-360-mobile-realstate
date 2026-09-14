import 'package:get/get.dart';

import '../../../data/datasources/notification_remote_datasource.dart';
import '../../../data/repositories/fake_notification_repository.dart';
import '../../../data/repositories/notification_repository_impl.dart';
import '../../../data/repositories/repo_registry.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    registerRepo<NotificationRepository>(
      (client) =>
          NotificationRepositoryImpl(NotificationRemoteDataSource(client)),
      FakeNotificationRepository.new,
    );
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(Get.find()),
    );
  }
}
