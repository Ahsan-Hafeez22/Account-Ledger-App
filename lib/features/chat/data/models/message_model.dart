import 'package:account_ledger/features/chat/domain/entities/message_entity.dart';

class MessageModel {
  final String messageId;
  final String chatRoomId;
  final String message;
  final String senderId;
  final String receiverId;
  final MessageStatus status;
  final DateTime createdAt;

  const MessageModel({
    required this.messageId,
    required this.chatRoomId,
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  MessageEntity toEntity() => MessageEntity(
    messageId: messageId,
    chatRoomId: chatRoomId,
    message: message,
    senderId: senderId,
    receiverId: receiverId,
    status: status,
    createdAt: createdAt,
  );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    String readIdLike(dynamic v) {
      if (v == null) return '';
      if (v is String) return v;
      if (v is Map) {
        final map = Map<String, dynamic>.from(v);
        final id = (map['_id'] ?? map['id'] ?? '').toString();
        return id;
      }
      return v.toString();
    }

    String readString(List<String> keys, {String fallback = ''}) {
      for (final k in keys) {
        final v = json[k];
        final s = readIdLike(v);
        if (s.isNotEmpty) return s;
      }
      return fallback;
    }

    DateTime readDateTime(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is String && v.isNotEmpty) {
          final parsed = DateTime.tryParse(v);
          if (parsed != null) return parsed.toUtc();
        }
        if (v is int) {
          // epoch milliseconds
          return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
        }
      }
      return DateTime.now().toUtc();
    }

    MessageStatus readStatus(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is String) {
          switch (v.toLowerCase()) {
            case 'sent':
              return MessageStatus.sent;
            case 'delivered':
              return MessageStatus.delivered;
            case 'read':
              return MessageStatus.read;
          }
        }
      }
      return MessageStatus.sent;
    }

    return MessageModel(
      // Backend uses `messageId` (uuid), while `_id` is Mongo doc id.
      messageId: readString(['messageId', 'message_id']),
      chatRoomId: readString(['chatRoomId', 'chat_room_id', 'roomId', 'room_id']),
      message: readString(['message', 'text', 'body']),
      // Backend uses `sender` and `receiver` (ObjectId string).
      senderId: readString(['senderId', 'sender_id', 'from', 'sender']),
      receiverId: readString(['receiverId', 'receiver_id', 'to', 'receiver']),
      status: readStatus(['status', 'messageStatus']),
      createdAt: readDateTime(['createdAt', 'created_at', 'timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatRoomId': chatRoomId,
      'message': message,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}

