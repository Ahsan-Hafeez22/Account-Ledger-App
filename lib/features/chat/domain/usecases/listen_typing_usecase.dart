import 'dart:async';

import 'package:account_ledger/features/chat/domain/repositories/chat_repository.dart';

class ListenTypingUseCase {
  final ChatRepository _repo;
  const ListenTypingUseCase(this._repo);

  Stream<TypingEvent> call() => _repo.listenToTyping();
}

