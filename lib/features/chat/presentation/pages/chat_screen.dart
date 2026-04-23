import 'dart:async';

import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/features/beneficiary/presentation/bloc/beneficiary_bloc.dart';
import 'package:account_ledger/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:account_ledger/features/chat/domain/entities/message_entity.dart';
import 'package:account_ledger/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:account_ledger/features/chat/presentation/utils/chat_time_formatters.dart';
import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  final String partnerId;
  const ChatScreen({super.key, required this.partnerId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  Timer? _typingDebounce;
  bool _opened = false;
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  static const int _limit = 20;

  String _currentUserId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) return authState.user.id;
    return '';
  }

  @override
  void dispose() {
    _typingDebounce?.cancel();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(BuildContext context, String text) {
    context.read<ChatBloc>().add(
          SendTyping(receiverId: widget.partnerId, isTyping: true),
        );
    // Emit socket typing with debounce (network friendly).
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(milliseconds: 700), () {
      context.read<ChatBloc>().add(
            SendTyping(receiverId: widget.partnerId, isTyping: false),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = _currentUserId(context);
    // Use the app-scoped ChatBloc (provided at root).
    if (!_opened) {
      _opened = true;
      context.read<ChatBloc>().add(OpenChat(partnerId: widget.partnerId));
      context.read<ChatBloc>().add(RequestUserStatus(userId: widget.partnerId));
      _page = 1;
      context.read<ChatBloc>().add(
            LoadChatHistory(
              myUserId: me,
              partnerId: widget.partnerId,
              page: _page,
              limit: _limit,
            ),
          );
      _scrollController.addListener(() {
        // With reverse: true, reaching maxScrollExtent means we're at the "top"/oldest end.
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 80) {
          _page += 1;
          context.read<ChatBloc>().add(
                LoadChatHistory(
                  myUserId: me,
                  partnerId: widget.partnerId,
                  page: _page,
                  limit: _limit,
                ),
              );
        }
      });
    }

    final partner = context.select<BeneficiaryBloc, BeneficiaryEntity?>(
      (b) {
        final items = b.state.items;
        for (final u in items) {
          if (u.userId == widget.partnerId) return u;
        }
        return null;
      },
    );
    final partnerName =
        (partner?.nickname.isNotEmpty == true ? partner!.nickname : partner?.userName) ??
            'Chat';

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ChatBloc, ChatState>(
          buildWhen: (p, c) =>
              p.userStatus[widget.partnerId] != c.userStatus[widget.partnerId] ||
              p.userLastSeen[widget.partnerId] != c.userLastSeen[widget.partnerId] ||
              p.typingUsers != c.typingUsers,
          builder: (context, state) {
            final online = state.userStatus[widget.partnerId] == true;
            final lastSeen = state.userLastSeen[widget.partnerId];
            final isTyping = state.typingUsers.contains(widget.partnerId);
            final statusText = isTyping
                ? 'Typing...'
                : (online
                    ? 'Online'
                    : (lastSeen != null
                        ? 'Last seen ${formatTimeAgo(lastSeen)}'
                        : 'Offline'));
            final statusColor = isTyping
                ? Colors.grey
                : (online ? Colors.green : Colors.grey);
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: (partner?.avatarUrl != null &&
                          partner!.avatarUrl!.isNotEmpty)
                      ? NetworkImage(partner.avatarUrl!)
                      : null,
                  child: (partner?.avatarUrl == null ||
                          (partner?.avatarUrl?.isEmpty ?? true))
                      ? Text(
                          partnerName.trim().isNotEmpty
                              ? partnerName.trim().characters.first.toUpperCase()
                              : 'C',
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partnerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (p, c) => p.messages != c.messages,
              builder: (context, state) {
                // ChatBloc holds messages for all chats (socket + history). Filter for this partner.
                final msgs = state.messages.where((m) {
                  final a = m.senderId == me && m.receiverId == widget.partnerId;
                  final b = m.senderId == widget.partnerId && m.receiverId == me;
                  return a || b;
                }).toList();
                if (msgs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final m = msgs[index];
                    final isMe = m.senderId == me;
                    return _MessageBubble(message: m, isMe: isMe);
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (v) => _onTextChanged(context, v),
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      final text = _controller.text;
                      _controller.clear();
                      context.read<ChatBloc>().add(
                            SendMessage(
                              receiverId: widget.partnerId,
                              message: text,
                              senderId: me,
                            ),
                          );
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isMe ? AppColors.primary : scheme.surfaceContainerHighest;
    final fg = isMe ? Colors.white : scheme.onSurface;
    final meta = isMe ? Colors.white70 : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(color: fg, height: 1.25, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatChatTime(message.createdAt),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: meta),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        _Ticks(status: message.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Ticks extends StatelessWidget {
  final MessageStatus status;
  const _Ticks({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 16, color: Colors.white70);
      case MessageStatus.delivered:
        // Grey double tick for delivered (clear on green bubble).
        return Icon(Icons.done_all, size: 16, color: Colors.grey.shade300);
      case MessageStatus.read:
        // White double tick for read (stands out on primary bubble).
        return const Icon(Icons.done_all, size: 16, color: Colors.white);
    }
  }
}

