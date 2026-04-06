import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';
import 'package:account_ledger/features/transaction/domain/repositories/transaction_repository.dart';

class GetTransactionDetailParams {
  final String transactionId;

  const GetTransactionDetailParams(this.transactionId);
}

class GetTransactionDetailUseCase
    implements UseCase<TransactionEntity, GetTransactionDetailParams> {
  final TransactionRepository _repository;

  GetTransactionDetailUseCase(this._repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(
    GetTransactionDetailParams params,
  ) {
    return _repository.getTransactionDetail(params.transactionId);
  }
}
