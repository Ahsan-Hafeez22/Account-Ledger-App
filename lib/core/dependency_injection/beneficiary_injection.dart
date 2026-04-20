import 'package:account_ledger/features/beneficiary/data/datasources/beneficiary_remote_datasource.dart';
import 'package:account_ledger/features/beneficiary/data/repositories/beneficiary_repository_impl.dart';
import 'package:account_ledger/features/beneficiary/domain/repositories/beneficiary_repository.dart';
import 'package:account_ledger/features/beneficiary/domain/usecases/add_beneficiary_usecase.dart';
import 'package:account_ledger/features/beneficiary/domain/usecases/delete_beneficiary_usecase.dart';
import 'package:account_ledger/features/beneficiary/domain/usecases/get_beneficiaries_usecase.dart';
import 'package:account_ledger/features/beneficiary/presentation/bloc/beneficiary_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

void initBeneficiaryInjection(GetIt sl) {
  sl.registerLazySingleton<BeneficiaryRemoteDatasource>(
    () => BeneficiaryRemoteDatasourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<BeneficiaryRepository>(
    () => BeneficiaryRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetBeneficiariesUseCase(sl()));
  sl.registerLazySingleton(() => AddBeneficiaryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBeneficiaryUseCase(sl()));

  sl.registerLazySingleton<BeneficiaryBloc>(
    () => BeneficiaryBloc(
      getBeneficiaries: sl(),
      addBeneficiary: sl(),
      deleteBeneficiary: sl(),
    )..add(const BeneficiariesLoadRequested()),
  );
}

