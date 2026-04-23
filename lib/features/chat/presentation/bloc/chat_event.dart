part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ConnectSocket extends ChatEvent {
  const ConnectSocket();
}

class DisconnectSocket extends ChatEvent {
  const DisconnectSocket();
}

class OpenChat extends ChatEvent {
  final String partnerId;
  const OpenChat({required this.partnerId});

  @override
  List<Object?> get props => [partnerId];
}

class SendMessage extends ChatEvent {
  final String receiverId;
  final String message;
  final String senderId;
  const SendMessage({
    required this.receiverId,
    required this.message,
    required this.senderId,
  });

  @override
  List<Object?> get props => [receiverId, message, senderId];
}

class SendTyping extends ChatEvent {
  final String receiverId;
  final bool isTyping;
  const SendTyping({required this.receiverId, required this.isTyping});

  @override
  List<Object?> get props => [receiverId, isTyping];
}

class ReceiveMessage extends ChatEvent {
  final MessageEntity message;
  const ReceiveMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageStatusUpdated extends ChatEvent {
  final MessageEntity message;
  const MessageStatusUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class TypingEventReceived extends ChatEvent {
  final TypingEvent event;
  const TypingEventReceived(this.event);

  @override
  List<Object?> get props => [event.userId, event.isTyping];
}

class UserStatusChanged extends ChatEvent {
  final UserStatusEvent event;
  const UserStatusChanged(this.event);

  @override
  List<Object?> get props => [event.userId, event.isOnline];
}

class ConnectionStatusChanged extends ChatEvent {
  final ChatConnectionStatus status;
  const ConnectionStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class RequestUserStatus extends ChatEvent {
  final String userId;
  const RequestUserStatus({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadChatHistory extends ChatEvent {
  final String myUserId;
  final String partnerId;
  final int page;
  final int limit;
  const LoadChatHistory({
    required this.myUserId,
    required this.partnerId,
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [myUserId, partnerId, page, limit];
}

class LoadChatPreview extends ChatEvent {
  final String myUserId;
  final String partnerId;
  const LoadChatPreview({required this.myUserId, required this.partnerId});

  @override
  List<Object?> get props => [myUserId, partnerId];
}

class ChatListUpdated extends ChatEvent {
  final ChatListUpdateEvent update;
  const ChatListUpdated(this.update);

  @override
  List<Object?> get props => [
        update.partnerId,
        update.latestMessage,
        update.latestMessageTime,
        update.unreadDelta,
        update.unreadCount,
        update.lastMessageStatus,
      ];
}

