import 'package:account_ledger/features/notification/domain/entities/app_notification_entity.dart';

abstract class NotificationRepository {
  Future<List<AppNotificationEntity>> getNotifications();
  Future<void> markRead(String notificationId);
  Future<void> markAllRead();
  Future<void> deleteOne(String notificationId);
  Future<void> deleteMany(List<String> ids);
}

