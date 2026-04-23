import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/features/beneficiary/presentation/bloc/beneficiary_bloc.dart';
import 'package:account_ledger/features/chat/domain/repositories/chat_repository.dart';
import 'package:account_ledger/features/chat/domain/entities/message_entity.dart';
import 'package:account_ledger/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:account_ledger/features/chat/presentation/utils/chat_time_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ChatUsersPage extends StatefulWidget {
  const ChatUsersPage({super.key});

  @override
  State<ChatUsersPage> createState() => _ChatUsersPageState();
}

class _ChatUsersPageState extends State<ChatUsersPage> {
  final Set<String> _requested = {};

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final myUserId = auth is AuthAuthenticated ? auth.user.id : '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (p, c) => p.connectionStatus != c.connectionStatus,
            builder: (context, state) {
              final (text, color) = switch (state.connectionStatus) {
                ChatConnectionStatus.connected => ('Connected', Colors.green),
                ChatConnectionStatus.connecting => (
                  'Connecting',
                  Colors.orange,
                ),
                ChatConnectionStatus.disconnected => ('Offline', Colors.grey),
                ChatConnectionStatus.error => ('Error', Colors.red),
              };
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: color),
                      const SizedBox(width: 6),
                      Text(
                        text,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<BeneficiaryBloc, BeneficiaryState>(
        buildWhen: (p, c) => p.items != c.items || p.loading != c.loading,
        builder: (context, bState) {
          if (bState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (bState.items.isEmpty) {
            return const Center(child: Text('No beneficiaries yet'));
          }

          final chatBloc = context.read<ChatBloc>();
          for (final u in bState.items) {
            if (u.userId.isEmpty) continue;
            if (_requested.add(u.userId)) {
              chatBloc.add(RequestUserStatus(userId: u.userId));
              if (myUserId.isNotEmpty) {
                chatBloc.add(
                  LoadChatPreview(myUserId: myUserId, partnerId: u.userId),
                );
              }
            }
          }

          final chatState = context.watch<ChatBloc>().state;
          final sortedUsers = List.of(bState.items);
          // Sort by last message time (desc). Users with no messages go to bottom.
          sortedUsers.sort((a, b) {
            final aTime =
                chatState.lastMessageByPartnerId[a.userId]?.createdAt;
            final bTime =
                chatState.lastMessageByPartnerId[b.userId]?.createdAt;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          return ListView.separated(
            itemCount: sortedUsers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = sortedUsers[index];
              return BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (p, c) =>
                    p.userStatus[user.userId] != c.userStatus[user.userId] ||
                    p.userLastSeen[user.userId] !=
                        c.userLastSeen[user.userId] ||
                    p.unreadCountByPartnerId[user.userId] !=
                        c.unreadCountByPartnerId[user.userId] ||
                    p.lastMessageStatusByPartnerId[user.userId] !=
                        c.lastMessageStatusByPartnerId[user.userId] ||
                    p.lastMessageIsMineByPartnerId[user.userId] !=
                        c.lastMessageIsMineByPartnerId[user.userId] ||
                    p.lastMessageByPartnerId[user.userId]?.messageId !=
                        c.lastMessageByPartnerId[user.userId]?.messageId,
                builder: (context, cState) {
                  // If last message changes, ensure list order updates too.
                  // (Triggers because this tile rebuilds; parent list will rebuild on next frame.)
                  final online = cState.userStatus[user.userId] == true;
                  final last = cState.lastMessageByPartnerId[user.userId];
                  final unread =
                      cState.unreadCountByPartnerId[user.userId] ?? 0;
                  final isMine =
                      cState.lastMessageIsMineByPartnerId[user.userId] == true;
                  final lastStatus =
                      cState.lastMessageStatusByPartnerId[user.userId];
                  final title = user.nickname.isNotEmpty
                      ? user.nickname
                      : user.userName;
                  final lastSeen = cState.userLastSeen[user.userId];
                  final offlineSubtitle = lastSeen != null
                      ? 'Last seen ${formatTimeAgo(lastSeen)}'
                      : 'Last seen recently';
                  final subtitleText = last?.message.isNotEmpty == true
                      ? last!.message
                      : (online ? 'Online' : offlineSubtitle);
                  final timeAgo = last != null
                      ? formatTimeAgo(last.createdAt)
                      : '';

                  return ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          child: Text(
                            title.trim().isNotEmpty
                                ? title.trim().characters.first.toUpperCase()
                                : 'C',
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: online ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      children: [
                        if (isMine && lastStatus != null)
                          _PreviewTicks(status: lastStatus),
                        if (isMine && lastStatus != null)
                          const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            subtitleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (timeAgo.isNotEmpty)
                          Text(
                            timeAgo,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        const SizedBox(height: 6),
                        if (unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      if (user.userId.isEmpty) return;
                      context.push(RouteEndpoints.chatPath(user.userId));
                    },
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ChatBloc, ChatState>(
        buildWhen: (p, c) =>
            p.connectionStatus != c.connectionStatus ||
            p.errorMessage != c.errorMessage,
        builder: (context, state) {
          if (state.errorMessage == null || state.errorMessage!.isEmpty) {
            return const SizedBox.shrink();
          }
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                state.errorMessage!,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PreviewTicks extends StatelessWidget {
  final MessageStatus status;
  const _PreviewTicks({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      MessageStatus.sent => Colors.grey,
      MessageStatus.delivered => Colors.grey,
      MessageStatus.read => Theme.of(context).colorScheme.primary,
    };
    final icon = switch (status) {
      MessageStatus.sent => Icons.check,
      MessageStatus.delivered => Icons.done_all,
      MessageStatus.read => Icons.done_all,
    };
    return Icon(icon, size: 16, color: color);
  }
}
