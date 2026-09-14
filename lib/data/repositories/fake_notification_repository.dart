import '../../core/error/result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

/// In-memory notifications for UI-first development (`Env.useFakeData`).
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository() : _items = _seed();

  List<AppNotification> _items;

  static List<AppNotification> _seed() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: '1',
        title: 'Visa decision due',
        body: 'Karim family — Schengen application decision expected today.',
        createdAt: now.subtract(const Duration(hours: 1)),
        read: false,
        kind: NotificationKind.visaDeadline,
      ),
      AppNotification(
        id: '2',
        title: 'Leave request',
        body: 'Rahim Uddin requested 2 days from Sunday.',
        createdAt: now.subtract(const Duration(hours: 4)),
        read: false,
        kind: NotificationKind.leave,
      ),
      AppNotification(
        id: '3',
        title: 'Payment received',
        body: '৳ 45,000 against invoice #2043.',
        createdAt: now.subtract(const Duration(hours: 9)),
        read: true,
        kind: NotificationKind.payment,
      ),
      AppNotification(
        id: '4',
        title: 'Passport expiring',
        body: "Nusrat J.'s passport expires in 30 days.",
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        read: true,
        kind: NotificationKind.documentExpiry,
      ),
      AppNotification(
        id: '5',
        title: 'Task assigned',
        body: 'Confirm hotel block for the Bali group.',
        createdAt: now.subtract(const Duration(days: 2)),
        read: true,
        kind: NotificationKind.task,
      ),
    ];
  }

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 350), () => value);

  @override
  Future<Result<List<AppNotification>>> list() =>
      _delayed(Result.ok(List.unmodifiable(_items)));

  @override
  Future<Result<void>> markRead(String id) {
    _items = [
      for (final n in _items)
        if (n.id == id) n.copyWith(read: true) else n,
    ];
    return _delayed(const Result.ok(null));
  }

  @override
  Future<Result<void>> markAllRead() {
    _items = [for (final n in _items) n.copyWith(read: true)];
    return _delayed(const Result.ok(null));
  }
}
