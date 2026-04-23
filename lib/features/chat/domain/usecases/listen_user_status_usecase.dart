import 'dart:async';

import 'package:account_ledger/features/chat/domain/repositories/chat_repository.dart';

class ListenUserStatusUseCase {
  final ChatRepository _repo;
  const ListenUserStatusUseCase(this._repo);

  Stream<UserStatusEvent> call() => _repo.listenToUserStatus();
}

class GetUserStatusUseCase {
  final ChatRepository _repo;
  const GetUserStatusUseCase(this._repo);

  Future<void> call({required String userId}) => _repo.getUserStatus(userId: userId);
}

