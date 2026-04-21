import 'package:account_ledger/features/account/domain/usecases/change_account_status.dart';
import 'package:account_ledger/features/account/domain/usecases/change_pin_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:account_ledger/features/account/data/datasources/account_remote_datasource.dart';
import 'package:account_ledger/features/account/data/repositories/account_repository_impl.dart';
import 'package:account_ledger/features/account/domain/repositories/account_repository.dart';
import 'package:account_ledger/features/account/domain/usecases/create_account_usecase.dart';
import 'package:account_ledger/features/account/domain/usecases/get_account_balance_usecase.dart';
import 'package:account_ledger/features/account/domain/usecases/get_accounts_usecase.dart';
import 'package:account_ledger/features/account/presentation/bloc/account_bloc.dart';

void initAccountInjection(GetIt sl) {
  sl.registerFactory(
    () => AccountBloc(
      getAccountsUseCase: sl(),
      createAccountUseCase: sl(),
      changeAccountStatusUsecase: sl(),
      changePinUsecase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetAccountsUseCase(sl()));
  sl.registerLazySingleton(() => GetAccountBalanceUseCase(sl()));
  sl.registerLazySingleton(() => CreateAccountUseCase(sl()));
  sl.registerLazySingleton(() => ChangeAccountStatusUsecase(sl()));
  sl.registerLazySingleton(() => ChangePinUsecase(sl()));

  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(remote: sl()),
  );

  sl.registerLazySingleton<AccountRemoteDatasource>(
    () => AccountRemoteDatasourceImpl(dio: sl()),
  );
}
