import 'package:account_ledger/features/chat/domain/repositories/chat_repository.dart';

class OpenChatUseCase {
  final ChatRepository _repo;
  const OpenChatUseCase(this._repo);

  Future<void> call({required String partnerId}) {
    return _repo.openChat(partnerId: partnerId);
  }
}

