import 'package:account_ledger/features/chat/domain/entities/message_entity.dart';
import 'package:account_ledger/features/chat/domain/repositories/chat_repository.dart';

class GetChatMessagesUseCase {
  final ChatRepository _repo;
  const GetChatMessagesUseCase(this._repo);

  Future<List<MessageEntity>> call({
    required String senderId,
    required String receiverId,
    required int page,
    required int limit,
  }) {
    return _repo.getMessages(
      senderId: senderId,
      receiverId: receiverId,
      page: page,
      limit: limit,
    );
  }
}

