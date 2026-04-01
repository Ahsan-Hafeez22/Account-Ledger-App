part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String defaultCurrency;
  final DateTime dateOfBirth;
  final String password;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.defaultCurrency,
    required this.dateOfBirth,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, phone, defaultCurrency, dateOfBirth, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCheckStatusRequested extends AuthEvent {
  const AuthCheckStatusRequested();
}

class AuthUnauthorizedDetected extends AuthEvent {
  const AuthUnauthorizedDetected();
}

class AuthUserLoaded extends AuthEvent {
  final UserEntity user;

  const AuthUserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class GoogleAuthRequested extends AuthEvent {
  const GoogleAuthRequested();
}
