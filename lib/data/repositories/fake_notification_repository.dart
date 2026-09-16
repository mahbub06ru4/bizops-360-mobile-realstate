import '../../core/error/result.dart';
import '../../core/routing/app_routes.dart';
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
      // Real-estate triggers (roadmap §7 Phase 3).
      AppNotification(
        id: '6',
        title: 'New property match',
        body: 'Khulshi Heights (A-3B) matches your saved requirement.',
        createdAt: now.subtract(const Duration(minutes: 20)),
        read: false,
        kind: NotificationKind.propertyMatch,
        route: Routes.propertyMatches,
      ),
      AppNotification(
        id: '7',
        title: 'Offer countered',
        body: 'The seller countered your offer on Share #1.',
        createdAt: now.subtract(const Duration(hours: 2)),
        read: false,
        kind: NotificationKind.offerUpdate,
        route: Routes.offers,
      ),
      AppNotification(
        id: '8',
        title: 'Site visit tomorrow',
        body: 'Site visit at Nasirabad Skyview Apartments, 11:00 AM.',
        createdAt: now.subtract(const Duration(hours: 5)),
        read: false,
        kind: NotificationKind.siteVisitReminder,
        route: Routes.siteVisits,
      ),
      AppNotification(
        id: '9',
        title: 'Installment overdue',
        body: 'Installment #6 for booking bk1 is overdue.',
        createdAt: now.subtract(const Duration(hours: 12)),
        read: true,
        kind: NotificationKind.installmentDue,
        route: Routes.reBookings,
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
