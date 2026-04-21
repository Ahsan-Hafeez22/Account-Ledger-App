import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/account/domain/repositories/account_repository.dart';
import 'package:dartz/dartz.dart';

class GetAccountBalanceUseCase extends UseCase<double, GetAccountBalanceParams> {
  final AccountRepository repository;
  GetAccountBalanceUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(GetAccountBalanceParams params) {
    return repository.getAccountBalance(accountNumber: params.accountNumber);
  }
}

class GetAccountBalanceParams {
  final String accountNumber;
  const GetAccountBalanceParams({required this.accountNumber});
}

