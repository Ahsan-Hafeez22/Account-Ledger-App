part of 'transaction_detail_bloc.dart';

sealed class TransactionDetailEvent extends Equatable {
  const TransactionDetailEvent();

  @override
  List<Object?> get props => [];
}

class TransactionDetailLoadRequested extends TransactionDetailEvent {
  final String transactionId;

  const TransactionDetailLoadRequested(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}
