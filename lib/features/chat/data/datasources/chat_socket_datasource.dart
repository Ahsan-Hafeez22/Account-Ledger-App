import 'dart:async';

import 'package:account_ledger/core/configs/env_config.dart';
import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/utils/logger.dart' as app_log;
import 'package:account_ledger/features/chat/data/models/message_model.dart';
import 'package:account_ledger/features/chat/domain/entities/message_entity.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

abstract interface class ChatSocketDataSource {
  Future<void> connect({required String token});
  Future<void> disconnect();

  void sendMessage({
    required String receiverId,
    required String message,
    required String clientMessageId,
  });

  void openChat({required String partnerId});

  void sendTyping({required String receiverId, required bool isTyping});

  void getUserStatus({required String userId});

  Stream<MessageModel> messages();
  Stream<MessageModel> messageStatus();
  Stream<TypingSocketEvent> typing();
  Stream<UserStatusSocketEvent> userStatus();
  Stream<ChatListUpdateSocketEvent> chatListUpdates();
  Stream<SocketConnectionStatus> connectionStatus();
}

enum SocketConnectionStatus { connecting, connected, disconnected, error }

class TypingSocketEvent {
  final String userId;
  final bool isTyping;
  const TypingSocketEvent({required this.userId, required this.isTyping});
}

class UserStatusSocketEvent {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeen;
  const UserStatusSocketEvent({
    required this.userId,
    required this.isOnline,
    required this.lastSeen,
  });
}

class ChatListUpdateSocketEvent {
  /// Partner userId (backend sends `fromUserId` but it represents the chat partner)
  final String partnerId;
  final String? latestMessage;
  final DateTime? latestMessageTime;
  final int? unreadDelta;
  final int? unreadCount;
  final String? lastMessageStatus;

  const ChatListUpdateSocketEvent({
    required this.partnerId,
    required this.latestMessage,
    required this.latestMessageTime,
    required this.unreadDelta,
    required this.unreadCount,
    required this.lastMessageStatus,
  });
}

class ChatSocketDataSourceImpl implements ChatSocketDataSource {
  ChatSocketDataSourceImpl();

  io.Socket? _socket;
  static const _tag = 'CHAT_SOCKET';

  final _messagesCtrl = StreamController<MessageModel>.broadcast();
  final _statusCtrl = StreamController<MessageModel>.broadcast();
  final _typingCtrl = StreamController<TypingSocketEvent>.broadcast();
  final _userStatusCtrl = StreamController<UserStatusSocketEvent>.broadcast();
  final _chatListCtrl =
      StreamController<ChatListUpdateSocketEvent>.broadcast();
  final _connectionCtrl =
      StreamController<SocketConnectionStatus>.broadcast();

  @override
  Stream<MessageModel> messages() => _messagesCtrl.stream;

  @override
  Stream<MessageModel> messageStatus() => _statusCtrl.stream;

  @override
  Stream<TypingSocketEvent> typing() => _typingCtrl.stream;

  @override
  Stream<UserStatusSocketEvent> userStatus() => _userStatusCtrl.stream;

  @override
  Stream<ChatListUpdateSocketEvent> chatListUpdates() => _chatListCtrl.stream;

  @override
  Stream<SocketConnectionStatus> connectionStatus() => _connectionCtrl.stream;

  String _socketUrlFromApiBaseUrl(String apiBaseUrl) {
    // Your app config uses ".../api". Socket servers are usually hosted at the same origin.
    // We normalize it to origin/root (no "/api").
    final uri = Uri.parse(apiBaseUrl);
    // Use origin only to avoid malformed URLs like "?#" when query/fragment are empty.
    // Example: "https://host.com/api" -> "https://host.com"
    return uri.origin;
  }

  io.Socket _ensureSocket() {
    final s = _socket;
    if (s == null) {
      throw const CacheException(
        message: 'Socket not initialized',
        code: 'socket-not-initialized',
        details: null,
      );
    }
    return s;
  }

  @override
  Future<void> connect({required String token}) async {
    if (token.isEmpty) {
      throw const AuthException(
        message: 'Missing auth token for socket connection',
        code: 'missing-socket-token',
        details: null,
      );
    }

    _connectionCtrl.add(SocketConnectionStatus.connecting);

    final socketUrl = _socketUrlFromApiBaseUrl(EnvConfig.development.baseUrl);
    app_log.log(_tag, 'Connecting to $socketUrl');

    // Ensure old socket is cleaned up
    try {
      await disconnect();
    } catch (_) {}

    final socket = io.io(
      socketUrl,
      io.OptionBuilder()
          // Allow polling fallback (some hosts/proxies block pure websocket).
          .setTransports(['websocket', 'polling'])
          .setPath('/socket.io')
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(800)
          .setReconnectionDelayMax(6000)
          .setTimeout(20000)
          // Many backends accept either "auth" object or Authorization header.
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket = socket;

    // If we never get connect/error callbacks (bad URL / blocked traffic),
    // don't leave UI stuck forever.
    Timer(const Duration(seconds: 15), () {
      final s = _socket;
      if (s == null) return;
      if (s.connected) return;
      app_log.log(_tag, 'Connect timeout (15s) - marking error');
      _connectionCtrl.add(SocketConnectionStatus.error);
    });

    socket.onConnect((_) {
      app_log.log(_tag, 'onConnect: id=${socket.id}');
      _connectionCtrl.add(SocketConnectionStatus.connected);
    });

    socket.onDisconnect((_) {
      app_log.log(_tag, 'onDisconnect');
      _connectionCtrl.add(SocketConnectionStatus.disconnected);
    });

    socket.onConnectError((err) {
      app_log.log(_tag, 'onConnectError: $err');
      _connectionCtrl.add(SocketConnectionStatus.error);
    });

    socket.onError((err) {
      app_log.log(_tag, 'onError: $err');
      _connectionCtrl.add(SocketConnectionStatus.error);
    });

    socket.onReconnectAttempt((attempt) {
      app_log.log(_tag, 'onReconnectAttempt: $attempt');
      _connectionCtrl.add(SocketConnectionStatus.connecting);
    });

    socket.onReconnect((attempt) {
      app_log.log(_tag, 'onReconnect: $attempt');
    });

    socket.onReconnectError((err) {
      app_log.log(_tag, 'onReconnectError: $err');
      _connectionCtrl.add(SocketConnectionStatus.error);
    });

    socket.onReconnectFailed((_) {
      app_log.log(_tag, 'onReconnectFailed');
      _connectionCtrl.add(SocketConnectionStatus.error);
    });

    socket.onAny((event, data) {
      // Keep this lightweight; useful for debugging server event names/payload shape.
      app_log.log(_tag, 'onAny: $event');
    });

    // ---- Listen to required events ----
    socket.on('new_message', (data) => _onMessageEvent(data, target: _messagesCtrl));
    // Backend emits full message payload for message_sent (use it to reconcile optimistic UI).
    socket.on('message_sent', (data) => _onMessageEvent(data, target: _messagesCtrl));
    // Backend emits {messageId, deliveredTo} for message_delivered.
    socket.on('message_delivered', (data) => _onMessageDelivered(data));
    socket.on('messages_delivered', (data) => _onBulkDelivered(data));
    socket.on('messages_read', (data) => _onBulkRead(data));
    socket.on('partner_typing', (data) => _onTyping(data));
    socket.on('user_online', (data) => _onUserOnlineOffline(data, true));
    socket.on('user_offline', (data) => _onUserOnlineOffline(data, false));
    socket.on('user_status', (data) => _onUserStatus(data));
    socket.on('chat_list_update', (data) => _onChatListUpdate(data));
    // Common variants
    socket.on('userStatus', (data) => _onUserStatus(data));
    socket.on('user-status', (data) => _onUserStatus(data));
    socket.on('online', (data) => _onUserOnlineOffline(data, true));
    socket.on('offline', (data) => _onUserOnlineOffline(data, false));

    socket.connect();
  }

  @override
  Future<void> disconnect() async {
    final socket = _socket;
    if (socket == null) return;

    app_log.log(_tag, 'disconnect()');
    socket.off('new_message');
    socket.off('message_sent');
    socket.off('message_delivered');
    socket.off('messages_delivered');
    socket.off('messages_read');
    socket.off('partner_typing');
    socket.off('user_online');
    socket.off('user_offline');
    socket.off('user_status');
    socket.off('chat_list_update');
    socket.off('userStatus');
    socket.off('user-status');
    socket.off('online');
    socket.off('offline');

    socket.dispose();
    _socket = null;
    _connectionCtrl.add(SocketConnectionStatus.disconnected);
  }

// ✅ Fixed — match your server exactly
@override
void sendMessage({
  required String receiverId,
  required String message,
  required String clientMessageId,
}) {
  final socket = _ensureSocket();
  socket.emit('send_message', {         // ← snake_case
    'receiverId': receiverId,
    'message': message,
  });
}

  void _onMessageDelivered(dynamic data) {
    try {
      app_log.log(_tag, 'message_delivered payload: $data');
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      final messageId = (map['messageId'] ?? '').toString();
      if (messageId.isEmpty) return;
      _statusCtrl.add(
        MessageModel(
          messageId: messageId,
          chatRoomId: '',
          message: '',
          senderId: '',
          receiverId: (map['deliveredTo'] ?? '').toString(),
          status: MessageStatus.delivered,
          createdAt: DateTime.now().toUtc(),
        ),
      );
    } catch (_) {}
  }

@override
void openChat({required String partnerId}) {
  final socket = _ensureSocket();
  app_log.log(_tag, 'emit open_chat partnerId=$partnerId');
  socket.emit('open_chat', {            // ← snake_case
    'partnerId': partnerId,
  });
}

@override
void sendTyping({required String receiverId, required bool isTyping}) {
  final socket = _ensureSocket();
  app_log.log(_tag, 'emit typing receiverId=$receiverId isTyping=$isTyping');
  socket.emit('typing', {               // ← server uses 'typing' not 'sendTyping'
    'receiverId': receiverId,
    'isTyping': isTyping,
  });
}

@override
void getUserStatus({required String userId}) {
  final socket = _ensureSocket();
  app_log.log(_tag, 'emit get_user_status targetUserId=$userId');
  socket.emit('get_user_status', {      // ← snake_case
    'targetUserId': userId,             // ← server expects 'targetUserId' not 'userId'
  });
}
  void _onMessageEvent(
    dynamic data, {
    required StreamController<MessageModel> target,
  }) {
    try {
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final m = MessageModel.fromJson(map);
        if (m.messageId.isEmpty) return;
        target.add(m);
        return;
      }
      // Some servers wrap payloads.
      if (data is List && data.isNotEmpty && data.first is Map) {
        final map = Map<String, dynamic>.from(data.first);
        final m = MessageModel.fromJson(map);
        if (m.messageId.isEmpty) return;
        target.add(m);
      }
    } catch (_) {}
  }

void _onBulkDelivered(dynamic data) {
  try {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      // Server tells us WHO delivered, not which specific messageIds
      // Use this to mark all messages to that user as delivered in your local state
      final byUserId   = map['byUserId'] as String?;    // who received them
      final fromUserId = map['fromUserId'] as String?;  // whose messages got delivered
      if (byUserId == null || fromUserId == null) return;

      // Emit a status update so your UI knows to update ticks
      _statusCtrl.add(
        MessageModel(
          messageId: '',           // empty = bulk update, not a single message
          chatRoomId: '',
          message: '',
          senderId: fromUserId,
          receiverId: byUserId,
          status: MessageStatus.delivered,
          createdAt: DateTime.now().toUtc(),
        ),
      );
    }
  } catch (_) {}
}

void _onBulkRead(dynamic data) {
  try {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final byUserId   = map['byUserId'] as String?;
      final fromUserId = map['fromUserId'] as String?;
      if (byUserId == null || fromUserId == null) return;

      _statusCtrl.add(
        MessageModel(
          messageId: '',
          chatRoomId: '',
          message: '',
          senderId: fromUserId,
          receiverId: byUserId,
          status: MessageStatus.read,
          createdAt: DateTime.now().toUtc(),
        ),
      );
    }
  } catch (_) {}
}
void _onTyping(dynamic data) {
  try {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final userId = map['senderId'] as String?;  // ← server sends 'senderId'
      final isTyping = map['isTyping'] == true;
      if (userId == null || userId.isEmpty) return;
      _typingCtrl.add(TypingSocketEvent(userId: userId, isTyping: isTyping));
    }
  } catch (_) {}
}
  void _onUserOnlineOffline(dynamic data, bool online) {
    try {
      app_log.log(_tag, 'user_${online ? 'online' : 'offline'} payload: $data');
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final userId =
            (map['userId'] ??
                    map['id'] ??
                    map['senderId'] ??
                    map['targetUserId'] ??
                    map['partnerId'])
                as String?;
        if (userId == null || userId.isEmpty) return;
        final lastSeenRaw = map['lastSeen'];
        final lastSeen = lastSeenRaw is String ? DateTime.tryParse(lastSeenRaw) : null;
        _userStatusCtrl.add(
          UserStatusSocketEvent(userId: userId, isOnline: online, lastSeen: lastSeen),
        );
      } else if (data is String && data.isNotEmpty) {
        _userStatusCtrl.add(
          UserStatusSocketEvent(userId: data, isOnline: online, lastSeen: null),
        );
      }
    } catch (_) {}
  }

  void _onUserStatus(dynamic data) {
    try {
      app_log.log(_tag, 'user_status payload: $data');
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final userId =
            (map['userId'] ??
                    map['id'] ??
                    map['targetUserId'] ??
                    map['partnerId'])
                as String?;
        final status = map['status'];
        final isOnline =
            map['isOnline'] == true ||
            map['online'] == true ||
            (status is String && status.toLowerCase() == 'online');
        final lastSeenRaw = map['lastSeen'];
        final lastSeen = lastSeenRaw is String ? DateTime.tryParse(lastSeenRaw) : null;
        if (userId == null || userId.isEmpty) return;
        _userStatusCtrl.add(
          UserStatusSocketEvent(userId: userId, isOnline: isOnline, lastSeen: lastSeen),
        );
      }
    } catch (_) {}
  }

  void _onChatListUpdate(dynamic data) {
    try {
      app_log.log(_tag, 'chat_list_update payload: $data');
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      final partnerId = (map['fromUserId'] ?? map['partnerId'] ?? '').toString();
      if (partnerId.isEmpty) return;
      final msg = map['latestMessage']?.toString();
      final timeRaw = map['latestMessageTime'];
      final time = timeRaw is String ? DateTime.tryParse(timeRaw) : null;
      final unreadDelta = map['unreadDelta'];
      final unreadCount = map['unreadCount'];
      final status = map['lastMessageStatus']?.toString();

      _chatListCtrl.add(
        ChatListUpdateSocketEvent(
          partnerId: partnerId,
          latestMessage: msg,
          latestMessageTime: time,
          unreadDelta: unreadDelta is int ? unreadDelta : int.tryParse('$unreadDelta'),
          unreadCount: unreadCount is int ? unreadCount : int.tryParse('$unreadCount'),
          lastMessageStatus: status,
        ),
      );
    } catch (_) {}
  }
}

