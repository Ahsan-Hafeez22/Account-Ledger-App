part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionLoadRequested extends TransactionEvent {
  const TransactionLoadRequested();
}

class TransactionLoadMoreRequested extends TransactionEvent {
  const TransactionLoadMoreRequested();
}

class TransferSubmitted extends TransactionEvent {
  final String toAccount;
  final String amount;
  final String? description;

  const TransferSubmitted({
    required this.toAccount,
    required this.amount,
    this.description,
  });

  @override
  List<Object?> get props => [toAccount, amount, description];
}

class TransactionMessageConsumed extends TransactionEvent {
  const TransactionMessageConsumed();
}
