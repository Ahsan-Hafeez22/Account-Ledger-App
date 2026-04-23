import 'dart:async';

import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/features/authentication/data/datasources/token_storage_datasource.dart';
import 'package:account_ledger/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:account_ledger/features/chat/data/datasources/chat_socket_datasource.dart';
import 'package:account_ledger/features/chat/domain/entities/message_entity.dart';
import 'package:account_ledger/features/chat/domain/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatSocketDataSource _socket;
  final ChatRemoteDataSource _remote;
  final TokenStorageDataSource _tokenStorage;
  final Uuid _uuid;

  ChatRepositoryImpl({
    required ChatSocketDataSource socket,
    required ChatRemoteDataSource remote,
    required TokenStorageDataSource tokenStorage,
    Uuid? uuid,
  }) : _socket = socket,
       _remote = remote,
       _tokenStorage = tokenStorage,
       _uuid = uuid ?? const Uuid();

  @override
  Future<void> connectSocket() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const AuthException(
        message: 'Missing access token',
        code: 'missing-access-token',
        details: null,
      );
    }
    await _socket.connect(token: token);
  }

  @override
  Future<void> disconnectSocket() => _socket.disconnect();

  @override
  Future<String> sendMessage({
    required String receiverId,
    required String message,
    String? clientMessageId,
  }) async {
    final id = (clientMessageId != null && clientMessageId.isNotEmpty)
        ? clientMessageId
        : _uuid.v4();
    _socket.sendMessage(
      receiverId: receiverId,
      message: message,
      clientMessageId: id,
    );
    return id;
  }

  @override
  Future<void> openChat({required String partnerId}) async {
    _socket.openChat(partnerId: partnerId);
  }

  @override
  Future<void> sendTyping({
    required String receiverId,
    required bool isTyping,
  }) async {
    _socket.sendTyping(receiverId: receiverId, isTyping: isTyping);
  }

  @override
  Stream<MessageEntity> listenToMessages() {
    return _socket.messages().map((m) => m.toEntity());
  }

  @override
  Stream<MessageEntity> listenToStatusUpdates() {
    return _socket.messageStatus().map((m) => m.toEntity());
  }

  @override
  Stream<TypingEvent> listenToTyping() {
    return _socket.typing().map(
          (e) => TypingEvent(userId: e.userId, isTyping: e.isTyping),
        );
  }

  @override
  Future<void> getUserStatus({required String userId}) async {
    _socket.getUserStatus(userId: userId);
  }

  @override
  Stream<UserStatusEvent> listenToUserStatus() {
    return _socket.userStatus().map(
          (e) => UserStatusEvent(
            userId: e.userId,
            isOnline: e.isOnline,
            lastSeen: e.lastSeen,
          ),
        );
  }

  @override
  Stream<ChatListUpdateEvent> listenToChatListUpdates() {
    MessageStatus? parseStatus(String? s) {
      if (s == null) return null;
      switch (s.toLowerCase()) {
        case 'sent':
          return MessageStatus.sent;
        case 'delivered':
          return MessageStatus.delivered;
        case 'read':
          return MessageStatus.read;
      }
      return null;
    }

    return _socket.chatListUpdates().map(
          (e) => ChatListUpdateEvent(
            partnerId: e.partnerId,
            latestMessage: e.latestMessage,
            latestMessageTime: e.latestMessageTime,
            unreadDelta: e.unreadDelta,
            unreadCount: e.unreadCount,
            lastMessageStatus: parseStatus(e.lastMessageStatus),
          ),
        );
  }

  @override
  Stream<ChatConnectionStatus> listenToConnectionStatus() {
    return _socket.connectionStatus().map((s) {
      switch (s) {
        case SocketConnectionStatus.connecting:
          return ChatConnectionStatus.connecting;
        case SocketConnectionStatus.connected:
          return ChatConnectionStatus.connected;
        case SocketConnectionStatus.disconnected:
          return ChatConnectionStatus.disconnected;
        case SocketConnectionStatus.error:
          return ChatConnectionStatus.error;
      }
    });
  }

  @override
  Future<List<MessageEntity>> getMessages({
    required String senderId,
    required String receiverId,
    required int page,
    required int limit,
  }) async {
    final models = await _remote.getMessages(
      senderId: senderId,
      receiverId: receiverId,
      page: page,
      limit: limit,
    );
    return models.map((m) => m.toEntity()).toList();
  }
}

