import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/account/domain/entities/account_entity.dart';
import 'package:account_ledger/features/account/domain/repositories/account_repository.dart';

class GetAccountsUseCase extends UseCase<AccountEntity?, NoParams> {
  final AccountRepository repository;

  GetAccountsUseCase(this.repository);

  @override
  Future<Either<Failure, AccountEntity?>> call(NoParams params) {
    return repository.getAccount();
  }
}
