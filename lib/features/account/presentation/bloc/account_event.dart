part of 'account_bloc.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class AccountLoadRequested extends AccountEvent {
  const AccountLoadRequested();
}

class ChangeAccountPinRequested extends AccountEvent {
  final String oldPin;
  final String newPin;
  const ChangeAccountPinRequested({required this.oldPin, required this.newPin});
}

class ChangeAccountStatusRequested extends AccountEvent {
  final String status;
  const ChangeAccountStatusRequested({required this.status});
}

class AccountCreateRequested extends AccountEvent {
  final String accountTitle;
  final String pin;

  const AccountCreateRequested({required this.accountTitle, required this.pin});

  @override
  List<Object?> get props => [accountTitle, pin];
}

class AccountErrorConsumed extends AccountEvent {
  const AccountErrorConsumed();
}
