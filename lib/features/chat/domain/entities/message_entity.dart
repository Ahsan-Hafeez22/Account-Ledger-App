import 'package:equatable/equatable.dart';

enum MessageStatus { sent, delivered, read }

class MessageEntity extends Equatable {
  final String messageId;
  final String chatRoomId;
  final String message;
  final String senderId;
  final String receiverId;
  final MessageStatus status;
  final DateTime createdAt;

  const MessageEntity({
    required this.messageId,
    required this.chatRoomId,
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  MessageEntity copyWith({
    String? messageId,
    String? chatRoomId,
    String? message,
    String? senderId,
    String? receiverId,
    MessageStatus? status,
    DateTime? createdAt,
  }) {
    return MessageEntity(
      messageId: messageId ?? this.messageId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    messageId,
    chatRoomId,
    message,
    senderId,
    receiverId,
    status,
    createdAt,
  ];
}

