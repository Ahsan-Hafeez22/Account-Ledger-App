import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';
import 'package:account_ledger/features/transaction/domain/repositories/transaction_repository.dart';

class CreateTransferParams {
  final String toAccount;
  final double amount;
  final String? description;

  const CreateTransferParams({
    required this.toAccount,
    required this.amount,
    this.description,
  });
}

class CreateTransferUseCase
    implements UseCase<TransactionEntity, CreateTransferParams> {
  final TransactionRepository _repository;

  CreateTransferUseCase(this._repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(
    CreateTransferParams params,
  ) {
    return _repository.createTransfer(
      toAccount: params.toAccount,
      amount: params.amount,
      description: params.description,
    );
  }
}
