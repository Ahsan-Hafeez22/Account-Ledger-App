part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

final class NotificationsLoadRequested extends NotificationEvent {
  const NotificationsLoadRequested();
}

final class NotificationsRefreshRequested extends NotificationEvent {
  const NotificationsRefreshRequested();
}

final class NotificationMarkReadRequested extends NotificationEvent {
  final String id;
  const NotificationMarkReadRequested(this.id);

  @override
  List<Object?> get props => [id];
}

final class NotificationsMarkAllReadRequested extends NotificationEvent {
  const NotificationsMarkAllReadRequested();
}

final class NotificationDeleteOneRequested extends NotificationEvent {
  final String id;
  const NotificationDeleteOneRequested(this.id);

  @override
  List<Object?> get props => [id];
}

final class NotificationsDeleteManyRequested extends NotificationEvent {
  final List<String> ids;
  const NotificationsDeleteManyRequested(this.ids);

  @override
  List<Object?> get props => [ids];
}

/// Used when an FCM push is received while app is running.
final class NotificationReceived extends NotificationEvent {
  final AppNotificationEntity notification;
  const NotificationReceived(this.notification);

  @override
  List<Object?> get props => [notification];
}

