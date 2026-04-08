import 'package:account_ledger/features/transaction/domain/usecases/verify_pin_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:account_ledger/features/transaction/data/datasources/transaction_pending_local_datasource.dart';
import 'package:account_ledger/features/transaction/data/datasources/transaction_remote_datasource.dart';
import 'package:account_ledger/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:account_ledger/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:account_ledger/features/transaction/domain/usecases/create_transfer_usecase.dart';
import 'package:account_ledger/features/transaction/domain/usecases/get_transaction_detail_usecase.dart';
import 'package:account_ledger/features/transaction/domain/usecases/get_transactions_usecase.dart';
import 'package:account_ledger/features/transaction/domain/usecases/recover_pending_transfer_usecase.dart';
import 'package:account_ledger/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:account_ledger/features/transaction/presentation/bloc/transaction_detail_bloc.dart';

void initTransactionInjection(GetIt sl) {
  sl.registerFactory(
    () => TransactionDetailBloc(getTransactionDetail: sl()),
  );
  sl.registerFactory(
    () => TransactionBloc(
      getTransactionsUseCase: sl(),
      createTransferUseCase: sl(),
      recoverPendingTransferUseCase: sl(),
      verifyPinUsecase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionDetailUseCase(sl()));
  sl.registerLazySingleton(() => CreateTransferUseCase(sl()));
  sl.registerLazySingleton(() => RecoverPendingTransferUseCase(sl()));
  sl.registerLazySingleton(() => VerfiyPinUsecase(sl()));

  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(remote: sl(), pending: sl()),
  );

  sl.registerLazySingleton<TransactionRemoteDatasource>(
    () => TransactionRemoteDatasourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<TransactionPendingLocalDatasource>(
    () => TransactionPendingLocalDatasourceImpl(secureStorage: sl()),
  );
}
