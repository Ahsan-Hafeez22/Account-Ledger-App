import 'package:account_ledger/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

void initNotificationInjection(GetIt sl) {
  sl.registerLazySingleton<NotificationRemoteDatasource>(
    () => NotificationRemoteDatasourceImpl(dio: sl<Dio>()),
  );
}

