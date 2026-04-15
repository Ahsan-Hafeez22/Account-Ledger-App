part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  final bool loading;
  final List<AppNotificationEntity> items;
  final String? errorMessage;
  final bool markingAll;
  final Set<String> busyIds; // per-item busy state for markRead/delete

  const NotificationState({
    required this.loading,
    required this.items,
    required this.errorMessage,
    required this.markingAll,
    required this.busyIds,
  });

  const NotificationState.initial()
      : loading = true,
        items = const [],
        errorMessage = null,
        markingAll = false,
        busyIds = const {};

  NotificationState copyWith({
    bool? loading,
    List<AppNotificationEntity>? items,
    String? errorMessage,
    bool clearError = false,
    bool? markingAll,
    Set<String>? busyIds,
  }) {
    return NotificationState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      markingAll: markingAll ?? this.markingAll,
      busyIds: busyIds ?? this.busyIds,
    );
  }

  bool get hasUnread => items.any((e) => !e.isRead);

  @override
  List<Object?> get props => [loading, items, errorMessage, markingAll, busyIds];
}

