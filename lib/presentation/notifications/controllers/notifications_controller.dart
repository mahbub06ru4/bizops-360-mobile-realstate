import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/state/async_value.dart';
import '../../../domain/entities/app_notification.dart';
import '../../../domain/repositories/notification_repository.dart';

/// A day-grouped slice of the list.
typedef NotificationGroup = ({String label, List<AppNotification> items});

class NotificationsController extends GetxController {
  NotificationsController(this._repo);

  final NotificationRepository _repo;

  final Rx<AsyncValue<List<AppNotification>>> state =
      const AsyncValue<List<AppNotification>>.loading().obs;

  int get unreadCount =>
      state.value.valueOrNull?.where((n) => !n.read).length ?? 0;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    final result = await _repo.list();
    state.value = result.fold(AsyncValue.data, AsyncValue.error);
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    await load();
  }

  Future<void> open(AppNotification n) async {
    if (!n.read) {
      await _repo.markRead(n.id);
      final current = state.value.valueOrNull;
      if (current != null) {
        state.value = AsyncValue.data([
          for (final x in current)
            if (x.id == n.id) x.copyWith(read: true) else x,
        ]);
      }
    }
    if (n.route != null) await Get.toNamed<void>(n.route!);
  }

  /// Splits the loaded list into Today / Earlier, preserving order.
  List<NotificationGroup> groupsFrom(List<AppNotification> items) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final today = items
        .where((n) => n.createdAt.isAfter(startOfToday))
        .toList(growable: false);
    final earlier = items
        .where((n) => !n.createdAt.isAfter(startOfToday))
        .toList(growable: false);
    return [
      if (today.isNotEmpty) (label: Tr.today, items: today),
      if (earlier.isNotEmpty) (label: Tr.earlier, items: earlier),
    ];
  }
}
