import 'package:get_it/get_it.dart';
import 'package:account_ledger/features/account/data/datasources/account_remote_datasource.dart';
import 'package:account_ledger/features/account/data/repositories/account_repository_impl.dart';
import 'package:account_ledger/features/account/domain/repositories/account_repository.dart';
import 'package:account_ledger/features/account/domain/usecases/create_account_usecase.dart';
import 'package:account_ledger/features/account/domain/usecases/get_accounts_usecase.dart';
import 'package:account_ledger/features/account/presentation/bloc/account_bloc.dart';

void initAccountInjection(GetIt sl) {
  sl.registerFactory(
    () => AccountBloc(
      getAccountsUseCase: sl(),
      createAccountUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetAccountsUseCase(sl()));
  sl.registerLazySingleton(() => CreateAccountUseCase(sl()));

  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(remote: sl()),
  );

  sl.registerLazySingleton<AccountRemoteDatasource>(
    () => AccountRemoteDatasourceImpl(dio: sl()),
  );
}
