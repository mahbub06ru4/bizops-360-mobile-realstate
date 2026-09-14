import 'package:bizops360_mobile/core/state/async_value.dart';
import 'package:bizops360_mobile/data/repositories/fake_notification_repository.dart';
import 'package:bizops360_mobile/domain/entities/app_notification.dart';
import 'package:bizops360_mobile/presentation/notifications/controllers/notifications_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NotificationsController controller;

  setUp(
    () => controller = NotificationsController(FakeNotificationRepository()),
  );

  test('load populates data and unread count', () async {
    await controller.load();
    final state = controller.state.value;
    expect(state, isA<AsyncData<List<AppNotification>>>());
    expect(state.valueOrNull, hasLength(5));
    expect(controller.unreadCount, 2);
  });

  test('markAllRead clears the unread count', () async {
    await controller.load();
    await controller.markAllRead();
    expect(controller.unreadCount, 0);
  });

  test('groupsFrom splits Today / Earlier', () async {
    await controller.load();
    final groups = controller.groupsFrom(controller.state.value.valueOrNull!);
    expect(
      groups.map((g) => g.label),
      containsAll(['common.today', 'common.earlier']),
    );
    final total = groups.fold<int>(0, (n, g) => n + g.items.length);
    expect(total, 5);
  });

  test('opening an unread notification marks it read', () async {
    await controller.load();
    final unread = controller.state.value.valueOrNull!.firstWhere(
      (n) => !n.read,
    );
    await controller.open(unread);
    final after = controller.state.value.valueOrNull!.firstWhere(
      (n) => n.id == unread.id,
    );
    expect(after.read, isTrue);
  });
}
