import 'dart:async';

import 'package:account_ledger/features/chat/domain/entities/message_entity.dart';
import 'package:account_ledger/features/chat/domain/repositories/chat_repository.dart';

class ListenMessagesUseCase {
  final ChatRepository _repo;
  const ListenMessagesUseCase(this._repo);

  Stream<MessageEntity> call() => _repo.listenToMessages();
}

class ListenMessageStatusUseCase {
  final ChatRepository _repo;
  const ListenMessageStatusUseCase(this._repo);

  Stream<MessageEntity> call() => _repo.listenToStatusUpdates();
}

