import 'package:account_ledger/features/account/domain/usecases/change_account_status.dart';
import 'package:account_ledger/features/account/domain/usecases/change_pin_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/account/domain/entities/account_entity.dart';
import 'package:account_ledger/features/account/domain/usecases/create_account_usecase.dart';
import 'package:account_ledger/features/account/domain/usecases/get_accounts_usecase.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccountsUseCase getAccountsUseCase;
  final CreateAccountUseCase createAccountUseCase;
  final ChangeAccountStatusUsecase changeAccountStatusUsecase;
  final ChangePinUsecase changePinUsecase;

  AccountBloc({
    required this.getAccountsUseCase,
    required this.createAccountUseCase,
    required this.changeAccountStatusUsecase,
    required this.changePinUsecase,
  }) : super(const AccountInitial()) {
    on<AccountLoadRequested>(_onLoadRequested);
    on<AccountCreateRequested>(_onCreateRequested);
    on<ChangeAccountPinRequested>(_onChangePinRequested);
    on<ChangeAccountStatusRequested>(_onChangeStatusRequested);
    on<AccountErrorConsumed>(_onErrorConsumed);
  }

  Future<void> _onLoadRequested(
    AccountLoadRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());
    final result = await getAccountsUseCase(const NoParams());
    result.fold(
      (failure) => emit(AccountFailure(failure.message)),
      (account) => emit(AccountLoaded(account: account)),
    );
  }

  Future<void> _onCreateRequested(
    AccountCreateRequested event,
    Emitter<AccountState> emit,
  ) async {
    final current = state;
    if (current is! AccountLoaded) return;

    emit(current.copyWith(isSubmitting: true, clearError: true));

    final result = await createAccountUseCase(
      CreateAccountParams(
        accountTitle: event.accountTitle.trim(),
        pin: event.pin.trim(),
      ),
    );

    await result.fold((failure) async {
      emit(current.copyWith(isSubmitting: false, errorMessage: failure.message));
    }, (_) async {
      final refreshed = await getAccountsUseCase(const NoParams());
      refreshed.fold(
        (failure) => emit(
          current.copyWith(isSubmitting: false, errorMessage: failure.message),
        ),
        (account) => emit(
          AccountLoaded(
            account: account,
            successMessage: 'Account created successfully',
          ),
        ),
      );
    });
  }

  Future<void> _onChangePinRequested(
    ChangeAccountPinRequested event,
    Emitter<AccountState> emit,
  ) async {
    final current = state;
    if (current is! AccountLoaded) return;
    if (current.account == null) return;

    emit(current.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    final result = await changePinUsecase(
      ChangePinParams(newPin: event.newPin.trim(), oldPin: event.oldPin.trim()),
    );

    await result.fold((failure) async {
      emit(current.copyWith(isSubmitting: false, errorMessage: failure.message));
    }, (_) async {
      final refreshed = await getAccountsUseCase(const NoParams());
      refreshed.fold(
        (failure) => emit(
          current.copyWith(isSubmitting: false, errorMessage: failure.message),
        ),
        (account) => emit(
          AccountLoaded(
            account: account,
            successMessage: 'Pin updated successfully',
          ),
        ),
      );
    });
  }

  Future<void> _onChangeStatusRequested(
    ChangeAccountStatusRequested event,
    Emitter<AccountState> emit,
  ) async {
    final current = state;
    if (current is! AccountLoaded) return;
    if (current.account == null) return;

    const allowed = {'ACTIVE', 'CLOSED', 'FROZEN'};
    final nextStatus = event.status.trim().toUpperCase();
    if (!allowed.contains(nextStatus)) {
      emit(current.copyWith(errorMessage: 'Invalid status', clearSuccess: true));
      return;
    }

    emit(current.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));

    final result = await changeAccountStatusUsecase(
      ChangeAccountStatusParams(nextStatus),
    );

    await result.fold((failure) async {
      emit(current.copyWith(isSubmitting: false, errorMessage: failure.message));
    }, (_) async {
      final refreshed = await getAccountsUseCase(const NoParams());
      refreshed.fold(
        (failure) => emit(
          current.copyWith(isSubmitting: false, errorMessage: failure.message),
        ),
        (account) => emit(
          AccountLoaded(
            account: account,
            successMessage: 'Account status updated',
          ),
        ),
      );
    });
  }

  void _onErrorConsumed(
    AccountErrorConsumed event,
    Emitter<AccountState> emit,
  ) {
    final current = state;
    if (current is AccountLoaded) {
      if (current.errorMessage != null) {
        emit(current.copyWith(clearError: true));
      } else if (current.successMessage != null) {
        emit(current.copyWith(clearSuccess: true));
      }
    }
  }
}
