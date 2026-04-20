import 'package:account_ledger/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:account_ledger/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:account_ledger/features/profile/domain/repositories/profile_repository.dart';
import 'package:account_ledger/features/profile/domain/usecases/edit_profile_usecase.dart';
import 'package:account_ledger/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

void initProfileInjection(GetIt sl) {
  sl.registerLazySingleton<ProfileRemoteDatasource>(
    () => ProfileRemoteDatasourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => EditProfileUseCase(sl()));
  sl.registerFactory(() => ProfileBloc(editProfileUseCase: sl()));
}

