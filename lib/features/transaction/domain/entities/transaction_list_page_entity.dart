import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_pagination_entity.dart';
import 'package:equatable/equatable.dart';

class TransactionListPageEntity extends Equatable {
  final List<TransactionEntity> transactions;
  final TransactionPaginationEntity pagination;

  const TransactionListPageEntity({
    required this.transactions,
    required this.pagination,
  });

  @override
  List<Object?> get props => [transactions, pagination];
}
