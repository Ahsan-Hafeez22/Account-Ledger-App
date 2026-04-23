import 'dart:async';

import 'package:account_ledger/features/chat/domain/entities/message_entity.dart';

abstract interface class ChatRepository {
  Future<void> connectSocket();
  Future<void> disconnectSocket();

  /// Returns the client message id used for optimistic UI reconciliation.
  Future<String> sendMessage({
    required String receiverId,
    required String message,
    String? clientMessageId,
  });

  Future<void> openChat({required String partnerId});

  Future<void> sendTyping({
    required String receiverId,
    required bool isTyping,
  });

  Stream<MessageEntity> listenToMessages();

  Stream<MessageEntity> listenToStatusUpdates();

  Stream<TypingEvent> listenToTyping();

  Future<void> getUserStatus({required String userId});

  Stream<UserStatusEvent> listenToUserStatus();

  Stream<ChatListUpdateEvent> listenToChatListUpdates();

  Stream<ChatConnectionStatus> listenToConnectionStatus();

  Future<List<MessageEntity>> getMessages({
    required String senderId,
    required String receiverId,
    required int page,
    required int limit,
  });
}

enum ChatConnectionStatus { connecting, connected, disconnected, error }

class TypingEvent {
  final String userId;
  final bool isTyping;
  const TypingEvent({required this.userId, required this.isTyping});
}

class UserStatusEvent {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeen;
  const UserStatusEvent({
    required this.userId,
    required this.isOnline,
    required this.lastSeen,
  });
}

class ChatListUpdateEvent {
  final String partnerId;
  final String? latestMessage;
  final DateTime? latestMessageTime;
  final int? unreadDelta;
  final int? unreadCount;
  final MessageStatus? lastMessageStatus;

  const ChatListUpdateEvent({
    required this.partnerId,
    required this.latestMessage,
    required this.latestMessageTime,
    required this.unreadDelta,
    required this.unreadCount,
    required this.lastMessageStatus,
  });
}

