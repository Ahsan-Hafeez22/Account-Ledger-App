import 'package:account_ledger/features/notification/domain/repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationRepository _repo;
  const MarkAllNotificationsReadUseCase(this._repo);

  Future<void> call() => _repo.markAllRead();
}

