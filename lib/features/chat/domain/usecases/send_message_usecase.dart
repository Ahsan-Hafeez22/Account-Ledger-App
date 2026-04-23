import 'package:account_ledger/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repo;
  const SendMessageUseCase(this._repo);

  Future<String> call({
    required String receiverId,
    required String message,
    String? clientMessageId,
  }) {
    return _repo.sendMessage(
      receiverId: receiverId,
      message: message,
      clientMessageId: clientMessageId,
    );
  }
}

