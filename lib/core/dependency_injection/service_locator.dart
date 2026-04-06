import 'package:account_ledger/core/configs/env_config.dart';
import 'package:account_ledger/core/theme/theme_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:account_ledger/core/dependency_injection/account_injection.dart';
import 'package:account_ledger/core/dependency_injection/auth_injection.dart';
import 'package:account_ledger/core/dependency_injection/transaction_injection.dart';
import 'package:account_ledger/core/network/api_client.dart';
import 'package:account_ledger/core/network/internet_checker.dart';
import 'package:account_ledger/core/storage/secure_storage_datasource.dart';
import 'package:account_ledger/features/authentication/data/datasources/token_storage_datasource.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:dio/dio.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton(() => ThemeCubit(sl<SharedPreferences>()));
  sl.registerLazySingleton<SecureStorageDataSource>(
    SecureStorageDataSourceImpl.new,
  );
  sl.registerLazySingleton<TokenStorageDataSource>(
    () => TokenStorageDataSourceImpl(secureStorage: sl()),
  );
  sl.registerLazySingleton<InternetConnection>(InternetConnection.new);
  sl.registerLazySingleton<InternetChecker>(() => InternetCheckerImpl(sl()));
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      baseUrl: EnvConfig.development.baseUrl,
      internetChecker: sl(),
      tokenStorage: sl(),
      onUnauthorized: () async {
        await sl<TokenStorageDataSource>().clearTokens();
        try {
          sl<AuthBloc>().add(const AuthUnauthorizedDetected());
        } catch (_) {}
      },
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // Features
  initAuthInjection(sl);
  initAccountInjection(sl);
  initTransactionInjection(sl);
  // initDashboardInjection(sl);
  // initAnalyticsInjection(sl);
  // initProfileInjection(sl);
}
