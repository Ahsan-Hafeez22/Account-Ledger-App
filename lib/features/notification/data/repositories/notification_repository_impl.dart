import 'package:account_ledger/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:account_ledger/features/notification/domain/entities/app_notification_entity.dart';
import 'package:account_ledger/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource _remote;

  const NotificationRepositoryImpl({required NotificationRemoteDatasource remote})
      : _remote = remote;

  @override
  Future<List<AppNotificationEntity>> getNotifications() async {
    final models = await _remote.getNotifications();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> markRead(String notificationId) => _remote.markRead(notificationId);

  @override
  Future<void> markAllRead() => _remote.markAllRead();

  @override
  Future<void> deleteOne(String notificationId) => _remote.deleteOne(notificationId);

  @override
  Future<void> deleteMany(List<String> ids) => _remote.deleteMany(ids);
}

