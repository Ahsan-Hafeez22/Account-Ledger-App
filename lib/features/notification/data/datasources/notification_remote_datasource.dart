import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/network/api_endpoints.dart';
import 'package:account_ledger/features/notification/data/models/app_notification_model.dart';
import 'package:dio/dio.dart';

abstract class NotificationRemoteDatasource {
  Future<List<AppNotificationModel>> getNotifications();
  Future<void> markRead(String notificationId);
  Future<void> markAllRead();
  Future<int> getUnreadCount();
  Future<void> deleteOne(String notificationId);
  Future<void> deleteMany(List<String> ids);
}

class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  final Dio dio;

  const NotificationRemoteDatasourceImpl({required this.dio});

  Never _throwTypedDio(DioException e, String scope) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    throw ServerException(
      message: 'Request failed. Please try again.',
      code: '$scope-failed-${statusCode ?? 'unknown'}',
      details: data ?? e.toString(),
    );
  }

  @override
  Future<List<AppNotificationModel>> getNotifications() async {
    try {
      final response = await dio.get(ApiEndpoints.getNotification);
      final data = response.data;

      // Accept multiple shapes:
      // - { notifications: [...] }
      // - { data: [...] }
      // - [ ... ]
      dynamic list = data;
      if (data is Map<String, dynamic>) {
        list =
            data['notifications'] ??
            data['data'] ??
            data['items'] ??
            data['results'];
      }
      if (list is! List) return const [];

      return list
          .whereType<Map>()
          .map(
            (e) => AppNotificationModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'get-notifications');
    }
  }

  @override
  Future<void> markRead(String notificationId) async {
    try {
      await dio.patch(ApiEndpoints.markNotificationRead(notificationId));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'mark-notification-read');
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await dio.patch(ApiEndpoints.markAllNotificationsRead);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'mark-all-notifications-read');
    }
  }

  @override
  Future<void> deleteOne(String notificationId) async {
    try {
      await dio.delete(ApiEndpoints.deleteNotification(notificationId));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'delete-notification');
    }
  }

  @override
  Future<void> deleteMany(List<String> ids) async {
    try {
      await dio.delete(
        ApiEndpoints.deleteManyNotifications,
        data: {'ids': ids},
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'delete-many-notifications');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dio.get(ApiEndpoints.unreadNotificationCount);
      final data = response.data;
      return data['count'];
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'delete-many-notifications');
    }
  }
}
