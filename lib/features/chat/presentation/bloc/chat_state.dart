part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final List<MessageEntity> messages;
  final Set<String> typingUsers;
  final Map<String, bool> userStatus;
  final Map<String, DateTime?> userLastSeen;
  final Map<String, int> unreadCountByPartnerId;
  final Map<String, MessageEntity> lastMessageByPartnerId;
  final Map<String, MessageStatus?> lastMessageStatusByPartnerId;
  final Map<String, bool> lastMessageIsMineByPartnerId;
  final ChatConnectionStatus connectionStatus;
  final bool isSending;
  final String? errorMessage;

  const ChatState({
    required this.messages,
    required this.typingUsers,
    required this.userStatus,
    required this.userLastSeen,
    required this.unreadCountByPartnerId,
    required this.lastMessageByPartnerId,
    required this.lastMessageStatusByPartnerId,
    required this.lastMessageIsMineByPartnerId,
    required this.connectionStatus,
    required this.isSending,
    required this.errorMessage,
  });

  factory ChatState.initial() => const ChatState(
        messages: [],
        typingUsers: {},
        userStatus: {},
        userLastSeen: {},
        unreadCountByPartnerId: {},
        lastMessageByPartnerId: {},
        lastMessageStatusByPartnerId: {},
        lastMessageIsMineByPartnerId: {},
        connectionStatus: ChatConnectionStatus.disconnected,
        isSending: false,
        errorMessage: null,
      );

  ChatState copyWith({
    List<MessageEntity>? messages,
    Set<String>? typingUsers,
    Map<String, bool>? userStatus,
    Map<String, DateTime?>? userLastSeen,
    Map<String, int>? unreadCountByPartnerId,
    Map<String, MessageEntity>? lastMessageByPartnerId,
    Map<String, MessageStatus?>? lastMessageStatusByPartnerId,
    Map<String, bool>? lastMessageIsMineByPartnerId,
    ChatConnectionStatus? connectionStatus,
    bool? isSending,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
      userStatus: userStatus ?? this.userStatus,
      userLastSeen: userLastSeen ?? this.userLastSeen,
      unreadCountByPartnerId:
          unreadCountByPartnerId ?? this.unreadCountByPartnerId,
      lastMessageByPartnerId:
          lastMessageByPartnerId ?? this.lastMessageByPartnerId,
      lastMessageStatusByPartnerId:
          lastMessageStatusByPartnerId ?? this.lastMessageStatusByPartnerId,
      lastMessageIsMineByPartnerId:
          lastMessageIsMineByPartnerId ?? this.lastMessageIsMineByPartnerId,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        typingUsers,
        userStatus,
        userLastSeen,
        unreadCountByPartnerId,
        lastMessageByPartnerId,
        lastMessageStatusByPartnerId,
        lastMessageIsMineByPartnerId,
        connectionStatus,
        isSending,
        errorMessage,
      ];
}

