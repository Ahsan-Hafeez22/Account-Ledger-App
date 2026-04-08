part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionLoadRequested extends TransactionEvent {
  final int page;
  final int limit;

  const TransactionLoadRequested({this.page = 1, this.limit = 10});
}

class VerfiyPinRequested extends TransactionEvent {
  final String pin;
  const VerfiyPinRequested({required this.pin});
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

class TransferWithPinSubmitted extends TransactionEvent {
  final String pin;
  final String toAccount;
  final String amount;
  final String? description;

  const TransferWithPinSubmitted({
    required this.pin,
    required this.toAccount,
    required this.amount,
    this.description,
  });

  @override
  List<Object?> get props => [pin, toAccount, amount, description];
}

class TransactionMessageConsumed extends TransactionEvent {
  const TransactionMessageConsumed();
}
