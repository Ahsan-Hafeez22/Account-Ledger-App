import 'dart:async';

import 'package:account_ledger/features/chat/domain/entities/message_entity.dart';
import 'package:account_ledger/features/chat/domain/repositories/chat_repository.dart';
import 'package:account_ledger/features/chat/domain/usecases/listen_messages_usecase.dart';
import 'package:account_ledger/features/chat/domain/usecases/listen_typing_usecase.dart';
import 'package:account_ledger/features/chat/domain/usecases/listen_user_status_usecase.dart';
import 'package:account_ledger/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import 'package:account_ledger/features/chat/domain/usecases/open_chat_usecase.dart';
import 'package:account_ledger/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class _PendingOutgoing {
  final String tempId;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime createdAt;

  const _PendingOutgoing({
    required this.tempId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
  });
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required ChatRepository repository,
    required SendMessageUseCase sendMessage,
    required OpenChatUseCase openChat,
    required ListenMessagesUseCase listenMessages,
    required ListenMessageStatusUseCase listenMessageStatus,
    required ListenTypingUseCase listenTyping,
    required ListenUserStatusUseCase listenUserStatus,
    required GetUserStatusUseCase getUserStatus,
    required GetChatMessagesUseCase getChatMessages,
    Uuid? uuid,
  })  : _repo = repository,
        _sendMessage = sendMessage,
        _openChat = openChat,
        _listenMessages = listenMessages,
        _listenMessageStatus = listenMessageStatus,
        _listenTyping = listenTyping,
        _listenUserStatus = listenUserStatus,
        _getUserStatus = getUserStatus,
        _getChatMessages = getChatMessages,
        _uuid = uuid ?? const Uuid(),
        super(ChatState.initial()) {
    on<ConnectSocket>(_onConnect);
    on<DisconnectSocket>(_onDisconnect);
    on<OpenChat>(_onOpenChat);
    on<SendMessage>(_onSend);
    on<SendTyping>(_onSendTyping);
    on<ReceiveMessage>(_onReceive);
    on<MessageStatusUpdated>(_onStatusUpdated);
    on<TypingEventReceived>(_onTyping);
    on<UserStatusChanged>(_onUserStatusChanged);
    on<ConnectionStatusChanged>(_onConnectionStatusChanged);
    on<RequestUserStatus>(_onRequestUserStatus);
    on<LoadChatHistory>(_onLoadChatHistory);
    on<LoadChatPreview>(_onLoadChatPreview);
    on<ChatListUpdated>(_onChatListUpdated);
  }

  final ChatRepository _repo;
  final SendMessageUseCase _sendMessage;
  final OpenChatUseCase _openChat;
  final ListenMessagesUseCase _listenMessages;
  final ListenMessageStatusUseCase _listenMessageStatus;
  final ListenTypingUseCase _listenTyping;
  final ListenUserStatusUseCase _listenUserStatus;
  final GetUserStatusUseCase _getUserStatus;
  final GetChatMessagesUseCase _getChatMessages;
  final Uuid _uuid;

  StreamSubscription<MessageEntity>? _msgSub;
  StreamSubscription<MessageEntity>? _statusSub;
  StreamSubscription<TypingEvent>? _typingSub;
  StreamSubscription<UserStatusEvent>? _userStatusSub;
  StreamSubscription<ChatConnectionStatus>? _connSub;
  StreamSubscription<ChatListUpdateEvent>? _chatListSub;

  final Map<String, int> _indexByMessageId = {};
  final Map<String, _PendingOutgoing> _pendingByTempId = {};

  bool _historyLoading = false;
  final Map<String, int> _historyPageByPartner = {};
  final Set<String> _historyHasMore = {};
  // reserved for future (avoid repeat initial calls) if needed
  bool _previewLoading = false;
  final Set<String> _previewRequested = {};

  Future<void> _onLoadChatPreview(
    LoadChatPreview event,
    Emitter<ChatState> emit,
  ) async {
    if (_previewLoading) return;
    if (_previewRequested.contains(event.partnerId)) return;
    _previewRequested.add(event.partnerId);
    _previewLoading = true;
    try {
      final list = await _getChatMessages(
        senderId: event.myUserId,
        receiverId: event.partnerId,
        page: 1,
        limit: 1,
      );
      if (list.isEmpty) return;
      final latest = list.reduce(
        (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
      );
      final next = Map<String, MessageEntity>.from(state.lastMessageByPartnerId);
      next[event.partnerId] = latest;
      emit(state.copyWith(lastMessageByPartnerId: next));
    } catch (_) {
      // ignore preview errors
    } finally {
      _previewLoading = false;
    }
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    if (_historyLoading) return;
    if (!_historyHasMore.contains(event.partnerId) && event.page > 1) return;

    _historyLoading = true;
    try {
      final list = await _getChatMessages(
        senderId: event.myUserId,
        receiverId: event.partnerId,
        page: event.page,
        limit: event.limit,
      );

      // Merge without duplicates; keep newest-first for reverse ListView.
      final existing = List<MessageEntity>.from(state.messages);
      final existingIds = existing.map((e) => e.messageId).toSet();

      final normalized = List<MessageEntity>.from(list)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final toAdd = normalized.where((m) => !existingIds.contains(m.messageId));
      final merged = [...existing, ...toAdd];
      merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _rebuildIndex(merged);

      _historyPageByPartner[event.partnerId] = event.page;
      if (list.length < event.limit) {
        _historyHasMore.remove(event.partnerId);
      } else {
        _historyHasMore.add(event.partnerId);
      }

      emit(state.copyWith(messages: merged));
      if (event.page == 1 && list.isNotEmpty) {
        final latest = merged.firstWhere(
          (m) =>
              (m.senderId == event.myUserId && m.receiverId == event.partnerId) ||
              (m.senderId == event.partnerId && m.receiverId == event.myUserId),
          orElse: () => list.first,
        );
        final next = Map<String, MessageEntity>.from(state.lastMessageByPartnerId);
        next[event.partnerId] = latest;
        emit(state.copyWith(lastMessageByPartnerId: next));
      }
    } catch (_) {
      // keep silent for now; UI can add a toast later
    } finally {
      _historyLoading = false;
    }
  }

  Future<void> _onConnect(ConnectSocket event, Emitter<ChatState> emit) async {
    emit(
      state.copyWith(
        errorMessage: null,
        connectionStatus: ChatConnectionStatus.connecting,
      ),
    );
    try {
      await _msgSub?.cancel();
      await _statusSub?.cancel();
      await _typingSub?.cancel();
      await _userStatusSub?.cancel();
      await _connSub?.cancel();
      await _chatListSub?.cancel();

      // Subscribe BEFORE connecting to avoid missing early events.
      _connSub = _repo
          .listenToConnectionStatus()
          .listen((s) => add(ConnectionStatusChanged(s)));

      await _repo.connectSocket();

      _msgSub = _listenMessages().listen((m) => add(ReceiveMessage(m)));
      _statusSub =
          _listenMessageStatus().listen((m) => add(MessageStatusUpdated(m)));
      _typingSub =
          _listenTyping().listen((e) => add(TypingEventReceived(e)));
      _userStatusSub =
          _listenUserStatus().listen((e) => add(UserStatusChanged(e)));
      _chatListSub =
          _repo.listenToChatListUpdates().listen((u) => add(ChatListUpdated(u)));
    } catch (e) {
      emit(
        state.copyWith(
          connectionStatus: ChatConnectionStatus.error,
          errorMessage: 'Socket connect failed',
        ),
      );
    }
  }

  Future<void> _onDisconnect(
    DisconnectSocket event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _repo.disconnectSocket();
    } catch (_) {}
    await _msgSub?.cancel();
    await _statusSub?.cancel();
    await _typingSub?.cancel();
    await _userStatusSub?.cancel();
    await _connSub?.cancel();
    await _chatListSub?.cancel();
    emit(state.copyWith(connectionStatus: ChatConnectionStatus.disconnected));
  }

  Future<void> _onOpenChat(OpenChat event, Emitter<ChatState> emit) async {
    try {
      await _openChat(partnerId: event.partnerId);
      await _getUserStatus(userId: event.partnerId);
      // Optimistic local reset (server also emits chat_list_update unreadCount: 0).
      final nextUnread = Map<String, int>.from(state.unreadCountByPartnerId);
      nextUnread[event.partnerId] = 0;
      emit(state.copyWith(unreadCountByPartnerId: nextUnread));
    } catch (_) {}
  }

  void _onChatListUpdated(ChatListUpdated event, Emitter<ChatState> emit) {
    final u = event.update;
    final nextUnread = Map<String, int>.from(state.unreadCountByPartnerId);
    final current = nextUnread[u.partnerId] ?? 0;

    if (u.unreadCount != null) {
      nextUnread[u.partnerId] = u.unreadCount!.clamp(0, 1 << 30);
    } else if (u.unreadDelta != null) {
      nextUnread[u.partnerId] = (current + u.unreadDelta!).clamp(0, 1 << 30);
    }

    var nextLast = state.lastMessageByPartnerId;
    var nextLastStatus = state.lastMessageStatusByPartnerId;
    var nextIsMine = state.lastMessageIsMineByPartnerId;
    if (u.latestMessage != null && u.latestMessageTime != null) {
      final msg = MessageEntity(
        messageId: 'preview-${u.partnerId}-${u.latestMessageTime!.millisecondsSinceEpoch}',
        chatRoomId: '',
        message: u.latestMessage!,
        senderId: '',
        receiverId: '',
        status: u.lastMessageStatus ?? MessageStatus.sent,
        createdAt: u.latestMessageTime!,
      );
      nextLast = Map<String, MessageEntity>.from(state.lastMessageByPartnerId);
      nextLast[u.partnerId] = msg;

      nextLastStatus =
          Map<String, MessageStatus?>.from(state.lastMessageStatusByPartnerId);
      nextLastStatus[u.partnerId] = u.lastMessageStatus;

      // Backend convention:
      // - sender receives chat_list_update with unreadDelta: 0 and lastMessageStatus set
      // - receiver receives chat_list_update with unreadDelta: +1 and no lastMessageStatus
      final mine = (u.unreadDelta == 0) && (u.lastMessageStatus != null);
      nextIsMine = Map<String, bool>.from(state.lastMessageIsMineByPartnerId);
      nextIsMine[u.partnerId] = mine;
    }

    emit(
      state.copyWith(
        unreadCountByPartnerId: nextUnread,
        lastMessageByPartnerId: nextLast,
        lastMessageStatusByPartnerId: nextLastStatus,
        lastMessageIsMineByPartnerId: nextIsMine,
      ),
    );
  }

  Future<void> _onSend(SendMessage event, Emitter<ChatState> emit) async {
    final trimmed = event.message.trim();
    if (trimmed.isEmpty) return;

    emit(state.copyWith(isSending: true, errorMessage: null));

    // Optimistic insert with a local temp id.
    // Backend does NOT accept/echo a clientMessageId, so we reconcile on `message_sent`.
    final tempId = _uuid.v4();
    final optimistic = MessageEntity(
      messageId: tempId,
      chatRoomId: '',
      message: trimmed,
      senderId: event.senderId,
      receiverId: event.receiverId,
      status: MessageStatus.sent,
      createdAt: DateTime.now().toUtc(),
    );

    _pendingByTempId[tempId] = _PendingOutgoing(
      tempId: tempId,
      senderId: event.senderId,
      receiverId: event.receiverId,
      message: trimmed,
      createdAt: optimistic.createdAt,
    );

    final nextMessages = [optimistic, ...state.messages];
    _rebuildIndex(nextMessages);
    emit(state.copyWith(messages: nextMessages));

    try {
      await _sendMessage(receiverId: event.receiverId, message: trimmed);
      emit(state.copyWith(isSending: false));
    } catch (e) {
      // Mark error in UI (keep message, allow retry later).
      emit(state.copyWith(isSending: false, errorMessage: 'Failed to send'));
    }
  }

  Future<void> _onSendTyping(SendTyping event, Emitter<ChatState> emit) async {
    try {
      await _repo.sendTyping(receiverId: event.receiverId, isTyping: event.isTyping);
    } catch (_) {}
  }

  void _onReceive(ReceiveMessage event, Emitter<ChatState> emit) {
    final m = event.message;
    if (m.messageId.isEmpty) return;

    // Reconcile optimistic outgoing message with server-ack (`message_sent`).
    final reconciled = _tryReconcileOutgoing(m);
    if (reconciled != null) {
      final nextPreview = Map<String, MessageEntity>.from(state.lastMessageByPartnerId);
      if (m.senderId.isNotEmpty && m.receiverId.isNotEmpty) {
        nextPreview[m.senderId] = m;
        nextPreview[m.receiverId] = m;
      }
      emit(state.copyWith(messages: reconciled, lastMessageByPartnerId: nextPreview));
      return;
    }

    final existingIndex = _indexByMessageId[m.messageId];
    if (existingIndex != null) {
      final updated = List<MessageEntity>.from(state.messages);
      updated[existingIndex] = _mergeMessage(updated[existingIndex], m);
      emit(state.copyWith(messages: updated));
      return;
    }

    final updated = [m, ...state.messages];
    _rebuildIndex(updated);
    // Keep preview up to date
    final nextPreview = Map<String, MessageEntity>.from(state.lastMessageByPartnerId);
    // message is "latest" for the other participant id if we know it
    if (m.senderId.isNotEmpty && m.receiverId.isNotEmpty) {
      // choose "other" as key by taking whichever is not empty; in chat list we key by partnerId
      // UI will request preview by partnerId anyway; this is a best-effort update.
      nextPreview[m.senderId] = m;
      nextPreview[m.receiverId] = m;
    }
    emit(state.copyWith(messages: updated, lastMessageByPartnerId: nextPreview));
  }

  void _onStatusUpdated(MessageStatusUpdated event, Emitter<ChatState> emit) {
    final m = event.message;
    // Backend bulk events (messages_delivered/messages_read) do not include messageId.
    // We model those as a MessageEntity with empty messageId and sender/receiver filled.
    if (m.messageId.isEmpty) {
      final fromUserId = m.senderId;
      final byUserId = m.receiverId;
      if (fromUserId.isEmpty || byUserId.isEmpty) return;

      final updated = List<MessageEntity>.from(state.messages);
      var changed = false;
      for (var i = 0; i < updated.length; i++) {
        final msg = updated[i];
        final matchesPair =
            msg.senderId == fromUserId && msg.receiverId == byUserId;
        if (!matchesPair) continue;

        // Only move status forward.
        final nextStatus = m.status;
        final current = msg.status;
        final shouldUpdate = switch (nextStatus) {
          MessageStatus.delivered =>
              current == MessageStatus.sent,
          MessageStatus.read =>
              current == MessageStatus.sent || current == MessageStatus.delivered,
          MessageStatus.sent => false,
        };
        if (!shouldUpdate) continue;

        updated[i] = msg.copyWith(status: nextStatus);
        changed = true;
      }
      if (changed) {
        // Update preview tick state for this partner (sender side).
        final nextStatus =
            Map<String, MessageStatus?>.from(state.lastMessageStatusByPartnerId);
        nextStatus[byUserId] = m.status;
        final nextMine =
            Map<String, bool>.from(state.lastMessageIsMineByPartnerId);
        nextMine[byUserId] = true;

        emit(
          state.copyWith(
            messages: updated,
            lastMessageStatusByPartnerId: nextStatus,
            lastMessageIsMineByPartnerId: nextMine,
          ),
        );
      }
      return;
    }

    final idx = _indexByMessageId[m.messageId];
    if (idx == null) return;

    final updated = List<MessageEntity>.from(state.messages);
    updated[idx] = updated[idx].copyWith(status: m.status);
    final msg = updated[idx];
    // Update preview tick status if this message is the latest outgoing to a partner.
    final partnerId = msg.receiverId;
    if (partnerId.isNotEmpty) {
      final nextStatus =
          Map<String, MessageStatus?>.from(state.lastMessageStatusByPartnerId);
      nextStatus[partnerId] = msg.status;
      final nextMine =
          Map<String, bool>.from(state.lastMessageIsMineByPartnerId);
      nextMine[partnerId] = true;
      emit(
        state.copyWith(
          messages: updated,
          lastMessageStatusByPartnerId: nextStatus,
          lastMessageIsMineByPartnerId: nextMine,
        ),
      );
    } else {
      emit(state.copyWith(messages: updated));
    }
  }

  void _onTyping(TypingEventReceived event, Emitter<ChatState> emit) {
    final userId = event.event.userId;
    final next = Set<String>.from(state.typingUsers);
    if (event.event.isTyping) {
      next.add(userId);
    } else {
      next.remove(userId);
    }
    emit(state.copyWith(typingUsers: next));
  }

  void _onUserStatusChanged(UserStatusChanged event, Emitter<ChatState> emit) {
    final next = Map<String, bool>.from(state.userStatus);
    next[event.event.userId] = event.event.isOnline;
    final nextLastSeen = Map<String, DateTime?>.from(state.userLastSeen);
    // Only update lastSeen when user is offline (server sends null when online).
    if (!event.event.isOnline) {
      nextLastSeen[event.event.userId] = event.event.lastSeen;
    } else {
      nextLastSeen[event.event.userId] = null;
    }
    emit(state.copyWith(userStatus: next, userLastSeen: nextLastSeen));
  }

  void _onConnectionStatusChanged(
    ConnectionStatusChanged event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(connectionStatus: event.status));
  }

  Future<void> _onRequestUserStatus(
    RequestUserStatus event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _getUserStatus(userId: event.userId);
    } catch (_) {}
  }

  MessageEntity _mergeMessage(MessageEntity old, MessageEntity incoming) {
    // Prefer server-provided fields if present.
    return old.copyWith(
      chatRoomId: incoming.chatRoomId.isNotEmpty ? incoming.chatRoomId : null,
      message: incoming.message.isNotEmpty ? incoming.message : null,
      senderId: incoming.senderId.isNotEmpty ? incoming.senderId : null,
      receiverId: incoming.receiverId.isNotEmpty ? incoming.receiverId : null,
      status: incoming.status,
      createdAt: incoming.createdAt,
    );
  }

  void _rebuildIndex(List<MessageEntity> messages) {
    _indexByMessageId
      ..clear()
      ..addEntries(
        messages.asMap().entries.map((e) => MapEntry(e.value.messageId, e.key)),
      );
  }

  List<MessageEntity>? _tryReconcileOutgoing(MessageEntity incoming) {
    // Find the newest pending outgoing that matches (same sender/receiver/message, close in time).
    _PendingOutgoing? match;
    for (final p in _pendingByTempId.values) {
      final samePair = p.senderId == incoming.senderId &&
          p.receiverId == incoming.receiverId;
      if (!samePair) continue;
      if (p.message != incoming.message) continue;
      final delta = incoming.createdAt.difference(p.createdAt).inSeconds.abs();
      if (delta > 30) continue;
      match = p;
      break;
    }
    if (match == null) return null;

    final tempIdx = _indexByMessageId[match.tempId];
    if (tempIdx == null) return null;

    final updated = List<MessageEntity>.from(state.messages);
    updated[tempIdx] = incoming;
    _pendingByTempId.remove(match.tempId);
    _rebuildIndex(updated);
    return updated;
  }

  @override
  Future<void> close() async {
    _pendingByTempId.clear();
    await _msgSub?.cancel();
    await _statusSub?.cancel();
    await _typingSub?.cancel();
    await _userStatusSub?.cancel();
    await _connSub?.cancel();
    await _chatListSub?.cancel();
    try {
      await _repo.disconnectSocket();
    } catch (_) {}
    return super.close();
  }
}

