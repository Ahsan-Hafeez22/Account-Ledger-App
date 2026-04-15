import 'package:account_ledger/features/notification/domain/repositories/notification_repository.dart';

class DeleteNotificationUseCase {
  final NotificationRepository _repo;
  const DeleteNotificationUseCase(this._repo);

  Future<void> call(String notificationId) => _repo.deleteOne(notificationId);
}

