import 'package:account_ledger/core/network/api_endpoints.dart';
import 'package:account_ledger/features/authentication/data/datasources/social_auth_datasource.dart';
import 'package:account_ledger/features/authentication/domain/usecases/google_auth_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:account_ledger/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:account_ledger/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:account_ledger/features/authentication/domain/repositories/auth_repository.dart';
import 'package:account_ledger/features/authentication/domain/usecases/login_usecase.dart';
import 'package:account_ledger/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:account_ledger/features/authentication/domain/usecases/register_usecase.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

void initAuthInjection(GetIt sl) {
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      googleAuthUsecase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GoogleAuthUsecase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDatasource: sl(),
      tokenStorageDatasource: sl(),
      socialAuthDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: ApiEndpoints.googleWebClientId,
    ),
  );
  // Data sources
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(dio: sl()),
  );
  // Data sources
  sl.registerLazySingleton<SocialAuthDataSource>(
    () => SocialAuthDataSourceImpl(googleSignIn: sl()),
  );
}
