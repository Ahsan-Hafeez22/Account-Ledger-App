import 'package:account_ledger/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:account_ledger/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:account_ledger/features/notification/domain/repositories/notification_repository.dart';
import 'package:account_ledger/features/notification/domain/usecases/delete_many_notifications_usecase.dart';
import 'package:account_ledger/features/notification/domain/usecases/delete_notification_usecase.dart';
import 'package:account_ledger/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:account_ledger/features/notification/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:account_ledger/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:account_ledger/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

void initNotificationInjection(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<NotificationRemoteDatasource>(
    () => NotificationRemoteDatasourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remote: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNotificationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteManyNotificationsUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => NotificationBloc(
      getNotifications: sl(),
      markRead: sl(),
      markAllRead: sl(),
      deleteOne: sl(),
      deleteMany: sl(),
    )..add(const NotificationsLoadRequested()),
  );
}

