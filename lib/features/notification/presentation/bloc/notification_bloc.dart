import 'package:account_ledger/features/notification/domain/entities/app_notification_entity.dart';
import 'package:account_ledger/features/notification/domain/usecases/delete_many_notifications_usecase.dart';
import 'package:account_ledger/features/notification/domain/usecases/delete_notification_usecase.dart';
import 'package:account_ledger/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:account_ledger/features/notification/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:account_ledger/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final DeleteNotificationUseCase _deleteOne;
  final DeleteManyNotificationsUseCase _deleteMany;

  NotificationBloc({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markRead,
    required MarkAllNotificationsReadUseCase markAllRead,
    required DeleteNotificationUseCase deleteOne,
    required DeleteManyNotificationsUseCase deleteMany,
  }) : _getNotifications = getNotifications,
       _markRead = markRead,
       _markAllRead = markAllRead,
       _deleteOne = deleteOne,
       _deleteMany = deleteMany,
       super(const NotificationState.initial()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationsRefreshRequested>(_onRefresh);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationsMarkAllReadRequested>(_onMarkAllRead);
    on<NotificationDeleteOneRequested>(_onDeleteOne);
    on<NotificationsDeleteManyRequested>(_onDeleteMany);
    on<NotificationReceived>(_onReceived);
  }

  Future<void> _onLoad(
    NotificationsLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final items = await _getNotifications();
      emit(state.copyWith(loading: false, items: items));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: 'Failed to load notifications',
        ),
      );
    }
  }

  Future<void> _onRefresh(
    NotificationsRefreshRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final items = await _getNotifications();
      emit(state.copyWith(items: items, clearError: true));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Refresh failed'));
    }
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.busyIds.contains(event.id)) return;
    final now = DateTime.now();
    final updated = state.items
        .map((e) => e.id == event.id ? e.copyWith(readAt: now) : e)
        .toList();
    emit(state.copyWith(items: updated, busyIds: {...state.busyIds, event.id}));
    try {
      await _markRead(event.id);
    } catch (_) {
      // Keep optimistic; next refresh reconciles.
    } finally {
      final nextBusy = {...state.busyIds}..remove(event.id);
      emit(state.copyWith(busyIds: nextBusy));
    }
  }

  Future<void> _onMarkAllRead(
    NotificationsMarkAllReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.markingAll || !state.hasUnread) return;
    final now = DateTime.now();
    emit(
      state.copyWith(
        markingAll: true,
        items: state.items.map((e) => e.isRead ? e : e.copyWith(readAt: now)).toList(),
      ),
    );
    try {
      await _markAllRead();
    } catch (_) {
      // Keep optimistic; next refresh reconciles.
    } finally {
      emit(state.copyWith(markingAll: false));
    }
  }

  Future<void> _onDeleteOne(
    NotificationDeleteOneRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.busyIds.contains(event.id)) return;
    final before = state.items;
    emit(
      state.copyWith(
        items: state.items.where((e) => e.id != event.id).toList(),
        busyIds: {...state.busyIds, event.id},
      ),
    );
    try {
      await _deleteOne(event.id);
    } catch (_) {
      emit(state.copyWith(items: before, errorMessage: 'Delete failed'));
    } finally {
      final nextBusy = {...state.busyIds}..remove(event.id);
      emit(state.copyWith(busyIds: nextBusy));
    }
  }

  Future<void> _onDeleteMany(
    NotificationsDeleteManyRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final ids = event.ids.toSet();
    if (ids.isEmpty) return;
    final before = state.items;
    emit(state.copyWith(items: state.items.where((e) => !ids.contains(e.id)).toList()));
    try {
      await _deleteMany(event.ids);
    } catch (_) {
      emit(state.copyWith(items: before, errorMessage: 'Delete failed'));
    }
  }

  void _onReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    final incoming = event.notification;
    if (incoming.id.isEmpty) return;

    // Prepend and dedupe by id.
    final next = <AppNotificationEntity>[
      incoming,
      ...state.items.where((e) => e.id != incoming.id),
    ];
    emit(state.copyWith(items: next, clearError: true));
  }
}

