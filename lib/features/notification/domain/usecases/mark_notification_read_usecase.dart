import 'package:account_ledger/features/notification/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository _repo;
  const MarkNotificationReadUseCase(this._repo);

  Future<void> call(String notificationId) => _repo.markRead(notificationId);
}

