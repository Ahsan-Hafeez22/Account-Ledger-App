part of 'balance_bloc.dart';

class BalanceState extends Equatable {
  final bool loading;
  final String accountNumber;
  final double? balance;
  final String? errorMessage;

  const BalanceState({
    required this.loading,
    required this.accountNumber,
    required this.balance,
    required this.errorMessage,
  });

  const BalanceState.initial()
      : loading = false,
        accountNumber = '',
        balance = null,
        errorMessage = null;

  BalanceState copyWith({
    bool? loading,
    String? accountNumber,
    double? balance,
    String? errorMessage,
  }) {
    return BalanceState(
      loading: loading ?? this.loading,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [loading, accountNumber, balance, errorMessage];
}

