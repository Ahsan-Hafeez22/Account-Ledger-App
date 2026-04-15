import 'package:account_ledger/features/notification/domain/entities/app_notification_entity.dart';
import 'package:account_ledger/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repo;
  const GetNotificationsUseCase(this._repo);

  Future<List<AppNotificationEntity>> call() => _repo.getNotifications();
}

