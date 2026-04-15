import 'package:account_ledger/features/notification/domain/repositories/notification_repository.dart';

class DeleteManyNotificationsUseCase {
  final NotificationRepository _repo;
  const DeleteManyNotificationsUseCase(this._repo);

  Future<void> call(List<String> ids) => _repo.deleteMany(ids);
}

