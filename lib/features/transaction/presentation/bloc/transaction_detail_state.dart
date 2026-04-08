part of 'transaction_detail_bloc.dart';

sealed class TransactionDetailState extends Equatable {
  const TransactionDetailState();

  @override
  List<Object?> get props => [];
}

class TransactionDetailInitial extends TransactionDetailState {
  const TransactionDetailInitial();
}

class TransactionDetailLoading extends TransactionDetailState {
  const TransactionDetailLoading();
}

class TransactionDetailFailure extends TransactionDetailState {
  final String message;

  const TransactionDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionDetailLoaded extends TransactionDetailState {
  final TransactionEntity transaction;

  const TransactionDetailLoaded(this.transaction);

  @override
  List<Object?> get props => [transaction];
}
