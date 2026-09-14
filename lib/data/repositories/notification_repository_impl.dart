import '../../core/error/result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_mappers.dart';
import 'remote_guard.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remote);

  final NotificationRemoteDataSource _remote;

  @override
  Future<Result<List<AppNotification>>> list() {
    return guardRequest(
      () async => (await _remote.list())
          .map(notificationFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<void>> markRead(String id) =>
      guardRequest(() => _remote.markRead(id));

  @override
  Future<Result<void>> markAllRead() => guardRequest(_remote.markAllRead);
}
