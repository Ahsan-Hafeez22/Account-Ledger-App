import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_list_page_entity.dart';
import 'package:account_ledger/features/transaction/domain/repositories/transaction_repository.dart';

class GetTransactionsParams {
  final int page;
  final int limit;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetTransactionsParams({
    this.page = 1,
    this.limit = 10,
    this.startDate,
    this.endDate,
  });
}

class GetTransactionsUseCase
    implements UseCase<TransactionListPageEntity, GetTransactionsParams> {
  final TransactionRepository _repository;

  GetTransactionsUseCase(this._repository);

  @override
  Future<Either<Failure, TransactionListPageEntity>> call(
    GetTransactionsParams params,
  ) {
    return _repository.getTransactions(
      page: params.page,
      limit: params.limit,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
