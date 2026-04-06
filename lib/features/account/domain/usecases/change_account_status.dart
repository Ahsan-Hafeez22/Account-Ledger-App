import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/account/domain/repositories/account_repository.dart';
import 'package:dartz/dartz.dart';

class ChangeAccountStatusUsecase
    extends UseCase<void, ChangeAccountStatusParams> {
  AccountRepository repository;
  ChangeAccountStatusUsecase(this.repository);
  @override
  Future<Either<Failure, void>> call(ChangeAccountStatusParams params) {
    return repository.changeAccountStatus(status: params.status);
  }
}

class ChangeAccountStatusParams {
  final String status;
  ChangeAccountStatusParams(this.status);
}
