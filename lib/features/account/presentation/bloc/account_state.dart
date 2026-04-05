part of 'account_bloc.dart';

const Object _kAccountCopyUnset = Object();

sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountFailure extends AccountState {
  final String message;

  const AccountFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountLoaded extends AccountState {
  /// `null` when the API returns 400 "No Account available" — show registration.
  final AccountEntity? account;
  final bool isSubmitting;
  final String? errorMessage;

  const AccountLoaded({
    this.account,
    this.isSubmitting = false,
    this.errorMessage,
  });

  AccountLoaded copyWith({
    Object? account = _kAccountCopyUnset,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AccountLoaded(
      account: identical(account, _kAccountCopyUnset)
          ? this.account
          : account as AccountEntity?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [account, isSubmitting, errorMessage];
}
