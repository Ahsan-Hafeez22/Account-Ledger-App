part of 'balance_bloc.dart';

sealed class BalanceEvent extends Equatable {
  const BalanceEvent();

  @override
  List<Object?> get props => [];
}

final class BalanceLoadRequested extends BalanceEvent {
  final String accountNumber;
  const BalanceLoadRequested({required this.accountNumber});

  @override
  List<Object?> get props => [accountNumber];
}

final class BalanceRefreshRequested extends BalanceEvent {
  final String accountNumber;
  const BalanceRefreshRequested({this.accountNumber = ''});

  @override
  List<Object?> get props => [accountNumber];
}

