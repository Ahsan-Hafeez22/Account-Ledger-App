import 'package:account_ledger/features/account/domain/usecases/get_account_balance_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'balance_event.dart';
part 'balance_state.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final GetAccountBalanceUseCase _getBalance;

  BalanceBloc({required GetAccountBalanceUseCase getAccountBalanceUseCase})
      : _getBalance = getAccountBalanceUseCase,
        super(const BalanceState.initial()) {
    on<BalanceLoadRequested>(_onLoad);
    on<BalanceRefreshRequested>(_onRefresh);
  }

  Future<void> _onLoad(
    BalanceLoadRequested event,
    Emitter<BalanceState> emit,
  ) async {
    if (event.accountNumber.isEmpty) return;
    emit(state.copyWith(loading: true, errorMessage: null, accountNumber: event.accountNumber));
    final res = await _getBalance(GetAccountBalanceParams(accountNumber: event.accountNumber));
    res.fold(
      (failure) => emit(state.copyWith(loading: false, errorMessage: failure.message)),
      (balance) => emit(state.copyWith(loading: false, balance: balance)),
    );
  }

  Future<void> _onRefresh(
    BalanceRefreshRequested event,
    Emitter<BalanceState> emit,
  ) async {
    final acct = event.accountNumber.isNotEmpty ? event.accountNumber : state.accountNumber;
    if (acct.isEmpty) return;
    emit(state.copyWith(loading: true, errorMessage: null, accountNumber: acct));
    final res = await _getBalance(GetAccountBalanceParams(accountNumber: acct));
    res.fold(
      (failure) => emit(state.copyWith(loading: false, errorMessage: failure.message)),
      (balance) => emit(state.copyWith(loading: false, balance: balance)),
    );
  }
}

