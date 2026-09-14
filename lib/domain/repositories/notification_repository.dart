import '../../core/error/result.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  /// Most-recent first.
  Future<Result<List<AppNotification>>> list();

  Future<Result<void>> markRead(String id);

  Future<Result<void>> markAllRead();
}
